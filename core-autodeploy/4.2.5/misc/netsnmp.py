#######################################################
# Version: 01a                                        #
#   Notes: This is a modified copy of the official    #
#          'netsnmp.py' that works with Ubuntu        #
#######################################################
import os
from ctypes import *
from ctypes.util import find_library
import CONSTANTS
from CONSTANTS import *

# freebsd cannot manage a decent find_library
import sys
if sys.platform.find('free') > -1:
    find_library_orig = find_library
    def find_library(name):
        for name in ['/usr/lib/lib%s.so' % name,
                     '/usr/local/lib/lib%s.so' % name]:
            if os.path.exists(name):
                return name
        return find_library_orig(name)

find_library_orig = find_library
def find_library(name):
    if sys.platform == "darwin":
        libPath = os.environ.get('DYLD_LIBRARY_PATH', '')
    else:
        libPath = os.environ.get('LD_LIBRARY_PATH', '')
    libPathList = libPath.split(':')
    for path in libPathList:
        pathName = path+'/lib%s.so' % name
        if os.path.exists(pathName):
            return pathName
    return find_library_orig(name)
    
import logging
log = logging.getLogger('zen.netsnmp')

c_int_p = c_void_p
authenticator = CFUNCTYPE(c_char_p, c_int_p, c_char_p, c_int)

try:
    # needed by newer netsnmp's
    crypto = CDLL(find_library('crypto'), RTLD_GLOBAL)
except Exception:
    import warnings
    warnings.warn("Unable to load crypto library")

lib = CDLL(find_library('netsnmp'), RTLD_GLOBAL)
lib.netsnmp_get_version.restype = c_char_p

oid = c_long
u_long = c_ulong
u_short = c_ushort
u_char_p = c_char_p
u_int = c_uint
size_t = c_size_t
u_char = c_byte

class netsnmp_session(Structure): pass
class netsnmp_pdu(Structure): pass
class netsnmp_transport(Structure): pass

# int (*netsnmp_callback) (int, netsnmp_session *, int, netsnmp_pdu *, void *);
netsnmp_callback = CFUNCTYPE(c_int,
                             c_int, POINTER(netsnmp_session),
                             c_int, POINTER(netsnmp_pdu),
                             c_void_p)

# int (*proc)(int, char * const *, int)
arg_parse_proc = CFUNCTYPE(c_int, POINTER(c_char_p), c_int);

version = lib.netsnmp_get_version()
_netsnmp_int_version = tuple(int(v) for v in version.split('.')[:3])

if _netsnmp_int_version < (5,1):
    raise ImportError("netsnmp version 5.1 or greater is required")
    

localname = []
securityAuthLocalKey = []
securityPrivLocalKey = []
paramName = []
transport_configuration =[]

if _netsnmp_int_version >= (5,2):
    localname = [('localname', c_char_p)]
    securityAuthLocalKey = [('securityAuthLocalKey', c_char_p), ('securityAuthLocalKeyLen', c_size_t)]
    securityPrivLocalKey = [('securityPrivLocalKey', c_char_p), ('securityPrivLocalKeyLen', c_size_t)]
    if _netsnmp_int_version >= (5,3):
        # paramName added
        paramName = [('paramName', c_char_p)]
        if _netsnmp_int_version >= (5,3):
            transport_configuration = [('transport_configuration', c_void_p)]
    
    

netsnmp_session._fields_ = [
        ('version', c_long),
        ('retries', c_int),
        ('timeout', c_long),
        ('flags', u_long),
        ('subsession', POINTER(netsnmp_session)),
        ('next', POINTER(netsnmp_session)),
        ('peername', c_char_p),
        ('remote_port', u_short)
        ] + localname + [
        ('local_port', u_short),
        ('authenticator', authenticator),
        ('callback', netsnmp_callback),
        ('callback_magic', c_void_p),
        ('s_errno', c_int),
        ('s_snmp_errno', c_int),
        ('sessid', c_long),
        ('community', u_char_p),
        ('community_len', size_t),
        ('rcvMsgMaxSize', size_t),
        ('sndMsgMaxSize', size_t),        
        ('isAuthoritative', u_char),
        ('contextEngineID', u_char_p),
        ('contextEngineIDLen', size_t),
        ('engineBoots', u_int),
        ('engineTime', u_int),
        ('contextName', c_char_p),
        ('contextNameLen', size_t),
        ('securityEngineID', u_char_p),
        ('securityEngineIDLen', size_t),
        ('securityName', c_char_p),
        ('securityNameLen', size_t),        
        ('securityAuthProto', POINTER(oid)),
        ('securityAuthProtoLen', size_t),
        ('securityAuthKey', u_char * USM_AUTH_KU_LEN),
        ('securityAuthKeyLen', c_size_t)
        ] + securityAuthLocalKey + [
        ('securityPrivProto', POINTER(oid)),
        ('securityPrivProtoLen', c_size_t),
        ('securityPrivKey', c_char * USM_PRIV_KU_LEN),
        ('securityPrivKeyLen', c_size_t)
        ] + securityPrivLocalKey + [
        ('securityModel', c_int),               # Reordered to match API order
        ('securityLevel', c_int)
        ] + paramName + [
        ('securityInfo', c_void_p)
        ] + transport_configuration + [
        ('myvoid', c_void_p)]
        


dataFreeHook = CFUNCTYPE(c_void_p)

class counter64(Structure):
    _fields_ = [
        ('high', c_ulong),
        ('low', c_ulong),
        ]

class netsnmp_vardata(Union):
    _fields_ = [
        ('integer', POINTER(c_long)),
        ('uinteger', POINTER(c_ulong)),
        ('string', c_char_p),
        ('objid', POINTER(oid)),
        ('bitstring', POINTER(c_ubyte)),
        ('counter64', POINTER(counter64)),
        ('floatVal', POINTER(c_float)),
        ('doubleVal', POINTER(c_double)),
        ]    

class netsnmp_variable_list(Structure):
    pass
netsnmp_variable_list._fields_ = [
        ('next_variable', POINTER(netsnmp_variable_list)),
        ('name', POINTER(oid)),
        ('name_length', c_size_t),
        ('type', c_char),
        ('val', netsnmp_vardata),
        ('val_len', c_size_t),
        ('name_loc', oid * MAX_OID_LEN),
        ('buf', c_char * 40),
        ('data', c_void_p),
        ('dataFreeHook', dataFreeHook),
        ('index', c_int),
        ]
    
netsnmp_pdu._fields_ = [
        ('version', c_long ),
        ('command', c_int ),
        ('reqid', c_long ),
        ('msgid', c_long ),
        ('transid', c_long ),
        ('sessid', c_long ),
        ('errstat', c_long ),
        ('errindex', c_long ),
        ('time', c_ulong ),
        ('flags', c_ulong ),
        ('securityModel', c_int ),
        ('securityLevel', c_int ),
        ('msgParseModel', c_int ),
        ('transport_data', c_void_p),
        ('transport_data_length', c_int ),
        ('tDomain', POINTER(oid)),
        ('tDomainLen', c_size_t ),
        ('variables', POINTER(netsnmp_variable_list)),
        ('community', c_char_p),
        ('community_len', c_size_t ),
        ('enterprise', POINTER(oid)),
        ('enterprise_length', c_size_t ),
        ('trap_type', c_long ),
        ('specific_type', c_long ),
        ('agent_addr', c_ubyte * 4),
        ('contextEngineID', c_char_p ),
        ('contextEngineIDLen', c_size_t ),
        ('contextName', c_char_p),
        ('contextNameLen', c_size_t ),
        ('securityEngineID', c_char_p),
        ('securityEngineIDLen', c_size_t ),
        ('securityName', c_char_p),
        ('securityNameLen', c_size_t ),
        ('priority', c_int ),
        ('range_subid', c_int ),
        ('securityStateRef', c_void_p),
        ]

netsnmp_pdu_p = POINTER(netsnmp_pdu)

# Redirect netsnmp logging to our log 
class netsnmp_log_message(Structure): pass
netsnmp_log_message_p = POINTER(netsnmp_log_message)
log_callback = CFUNCTYPE(c_int, c_int,
                         netsnmp_log_message_p,
                         c_void_p);
netsnmp_log_message._fields_ = [
    ('priority', c_int),
    ('msg', c_char_p),
]
PRIORITY_MAP = {
    LOG_EMERG     : logging.CRITICAL + 2,
    LOG_ALERT     : logging.CRITICAL + 1,
    LOG_CRIT      : logging.CRITICAL,
    LOG_ERR       : logging.ERROR,
    LOG_WARNING   : logging.WARNING,
    LOG_NOTICE    : logging.INFO + 1,
    LOG_INFO      : logging.INFO,
    LOG_DEBUG     : logging.DEBUG,
    }
def netsnmp_logger(a, b, msg):
    msg = cast(msg, netsnmp_log_message_p)
    priority = PRIORITY_MAP.get(msg.contents.priority, logging.DEBUG)
    log.log(priority, str(msg.contents.msg).strip())
    return 0
netsnmp_logger = log_callback(netsnmp_logger)
lib.snmp_register_callback(SNMP_CALLBACK_LIBRARY,
                           SNMP_CALLBACK_LOGGING,
                           netsnmp_logger,
                           0)
lib.netsnmp_register_loghandler(NETSNMP_LOGHANDLER_CALLBACK, LOG_DEBUG)
lib.snmp_pdu_create.restype = netsnmp_pdu_p
lib.snmp_open.restype = POINTER(netsnmp_session)


netsnmp_transport._fields_ = [
    ('domain', POINTER(oid)),
    ('domain_length', c_int),
    ('local', u_char_p),
    ('local_length', c_int),
    ('remote', u_char_p),
    ('remote_length', c_int),
    ('sock', c_int),
    ('flags', u_int),
    ('data', c_void_p),
    ('data_length', c_int),
    ('msgMaxSize', c_size_t),
    ('f_recv', c_void_p),
    ('f_send', c_void_p),
    ('f_close', c_void_p),
    ('f_accept',  c_void_p),
    ('f_fmtaddr', c_void_p),
]
lib.netsnmp_tdomain_transport.restype = POINTER(netsnmp_transport)

lib.snmp_add.restype = POINTER(netsnmp_session)
lib.snmp_add_var.argtypes = [
    netsnmp_pdu_p, POINTER(oid), c_size_t, c_char, c_char_p]

lib.get_uptime.restype = c_long

lib.snmp_send.argtypes = (POINTER(netsnmp_session), netsnmp_pdu_p)
lib.snmp_send.restype = c_int

# int snmp_input(int, netsnmp_session *, int, netsnmp_pdu *, void *);
snmp_input_t = CFUNCTYPE(c_int,
                         c_int,
                         POINTER(netsnmp_session),
                         c_int,
                         netsnmp_pdu_p,
                         c_void_p)

class UnknownType(Exception):
    pass

def mkoid(n):
    oids = (oid * len(n))()
    for i, v in enumerate(n):
        oids[i] = v
    return oids

def strToOid(oidStr):
    return mkoid(tuple([int(x) for x in oidStr.strip('.').split('.')]))

def decodeOid(pdu):
    return tuple([pdu.val.objid[i] for i in range(pdu.val_len / sizeof(u_long))])

def decodeIp(pdu):
    return '.'.join(map(str, pdu.val.bitstring[:4]))

def decodeBigInt(pdu):
    int64 = pdu.val.counter64.contents
    return (int64.high << 32L) + int64.low

def decodeString(pdu):
    if pdu.val_len:
        return string_at(pdu.val.bitstring, pdu.val_len)
    return ''

_valueToConstant = dict([(chr(getattr(CONSTANTS, k)), k) for k in CONSTANTS.__dict__.keys() if isinstance(getattr(CONSTANTS,k), int) and getattr(CONSTANTS,k)>=0 and getattr(CONSTANTS,k) < 256])


decoder = {
    chr(ASN_OCTET_STR): decodeString,
    # chr(ASN_BOOLEAN): lambda pdu: pdu.val.integer.contents.value,
    chr(ASN_INTEGER): lambda pdu: pdu.val.integer.contents.value,
    chr(ASN_NULL): lambda pdu: None,
    chr(ASN_OBJECT_ID): decodeOid,
    chr(ASN_BIT_STR): decodeString,
    chr(ASN_IPADDRESS): decodeIp,
    chr(ASN_COUNTER): lambda pdu: pdu.val.uinteger.contents.value,
    chr(ASN_GAUGE): lambda pdu: pdu.val.uinteger.contents.value,
    chr(ASN_TIMETICKS): lambda pdu: pdu.val.uinteger.contents.value,
    chr(ASN_COUNTER64): decodeBigInt,
    chr(ASN_APP_FLOAT): lambda pdu: pdu.val.float.contents.value,
    chr(ASN_APP_DOUBLE): lambda pdu: pdu.val.double.contents.value,
    }

def decodeType(var):
    oid = [var.name[i] for i in range(var.name_length)]
    decode = decoder.get(var.type, None)
    if not decode:
        # raise UnknownType(oid, ord(var.type))
        log_oid = ".".join(map(str, oid))
        log.debug("No decoder for oid %s type %s - returning None", log_oid, 
                 _valueToConstant.get(var.type, var.type))
        return (oid, None)
    return oid, decode(var)
    

def getResult(pdu):
    result = []
    var = pdu.variables
    while var:
        var = var.contents
        oid, val = decodeType(var)
        result.append( (tuple(oid), val) )
        var = var.next_variable
    return result

class SnmpError(Exception):

    def __init__(self, why):
        lib.snmp_perror(why)
        Exception.__init__(self, why)

class SnmpTimeoutError(Exception):
    pass

sessionMap = {}
def _callback(operation, sp, reqid, pdu, magic):
    sess = sessionMap[magic]
    try:
        if operation == NETSNMP_CALLBACK_OP_RECEIVED_MESSAGE:
            sess.callback(pdu.contents)
        elif operation == NETSNMP_CALLBACK_OP_TIMED_OUT:
            sess.timeout(reqid)
        else:
            log.error("Unknown operation: %d", operation)
    except Exception, ex:
        log.exception("Exception in _callback %s", ex)
    return 1
_callback = netsnmp_callback(_callback)

class ArgumentParseError(Exception):
    pass

class TransportError(Exception):
    pass

def _doNothingProc(argc, argv, arg):
    return 0
_doNothingProc = arg_parse_proc(_doNothingProc)

def parse_args(args, session):
    import sys
    args = [sys.argv[0],] + args
    argc = len(args)
    argv = (c_char_p * argc)()
    for i in range(argc):
        # snmp_parse_args mutates argv, so create a copy
        argv[i] = create_string_buffer(args[i]).raw
    if lib.snmp_parse_args(argc, argv, session, '', _doNothingProc) < 0:
        def toList(args):
            return [str(x) for x in args]
        raise ArgumentParseError("Unable to parse arguments", toList(argv))
    # keep a reference to the args for as long as sess is alive
    return argv

def initialize_session(sess, cmdLineArgs, kw):
    args = None
    kw = kw.copy()
    if cmdLineArgs:
        cmdLine = [x for x in cmdLineArgs]
        if isinstance(cmdLine[0], tuple):
            result = []
            for opt, val in cmdLine:
                result.append(opt)
                result.append(val)
            cmdLine = result
        if kw.get('peername'):
            cmdLine.append(kw['peername'])
            del kw['peername']
        args = parse_args(cmdLine, byref(sess))
    for attr, value in kw.items():
        setattr(sess, attr, value)
    return args

class Session(object):

    cb = None

    def __init__(self, cmdLineArgs = (), **kw):
        self.cmdLineArgs = cmdLineArgs
        self.kw = kw
        self.sess = None
        self.args = None

    def open(self):
        sess = netsnmp_session()
        lib.snmp_sess_init(byref(sess))
        self.args = initialize_session(sess, self.cmdLineArgs, self.kw)
        sess.callback = _callback
        sess.callback_magic = id(self)
        sess = lib.snmp_open(byref(sess))
        self.sess = sess # cast(sess, POINTER(netsnmp_session))
        if not self.sess:
            raise SnmpError('snmp_open')
        sessionMap[id(self)] = self
        
    def awaitTraps(self, peername, fileno = -1, pre_parse_callback=None, debug=False):
        if _netsnmp_int_version >= (5,3):
            lib.netsnmp_ds_set_string(NETSNMP_DS_LIBRARY_ID, NETSNMP_DS_LIB_APPTYPE, 'zentrapd')        
        lib.init_usm()
        if debug:
            lib.debug_register_tokens("snmp_parse") # or "ALL" for everything
            lib.snmp_set_do_debugging(1)
        lib.netsnmp_udp_ctor()
        marker = object()
        if getattr(lib, "netsnmp_udpipv6_ctor", marker) is not marker:
            lib.netsnmp_udpipv6_ctor()
        elif getattr(lib, "netsnmp_udp6_ctor", marker) is not marker:
            lib.netsnmp_udp6_ctor()
        else:
            log.debug("Cannot find constructor function for UDP/IPv6 transport domain object.")
        lib.init_snmpv3(None)
        lib.setup_engineID(None, None)
        transport = lib.netsnmp_tdomain_transport(peername, 1, "udp")
        if not transport:
            raise SnmpError("Unable to create transport {peername}".format(peername=peername))
        if fileno >= 0:
            os.dup2(fileno, transport.contents.sock)
        sess = netsnmp_session()
        
        self.sess = pointer(sess)
        lib.snmp_sess_init(self.sess)
        sess.peername = SNMP_DEFAULT_PEERNAME
        sess.version = SNMP_DEFAULT_VERSION
        sess.community_len = SNMP_DEFAULT_COMMUNITY_LEN
        sess.retries = SNMP_DEFAULT_RETRIES
        sess.timeout = SNMP_DEFAULT_TIMEOUT
        sess.callback = _callback
        sess.callback_magic = id(self)
        # sess.authenticator = None
        sess.isAuthoritative = SNMP_SESS_UNKNOWNAUTH
        rc = lib.snmp_add(self.sess, transport, pre_parse_callback, None)
        if not rc:
            raise SnmpError('snmp_add')
        sessionMap[id(self)] = self

    def create_users(self, users):
        log.debug("create_users: Creating %s users." % len(users))
        for user in users:
            if user.version == 3:
                try:
                    line = " ".join(["-e",
                                     user.engine_id,
                                     user.username,
                                     user.authentication_type, # MD5 or SHA
                                     user.authentication_passphrase,
                                     user.privacy_protocol, # DES or AES
                                     user.privacy_passphrase])
                    lib.usm_parse_create_usmUser("createUser", line)
                    log.debug("create_users: created user: %s" % user)
                except StandardError, e:
                    log.debug("create_users: could not create user: %s: (%s: %s)" % (user, e.__class__.__name__, e))

    def sendTrap(self, trapoid, varbinds=None):
        pdu = lib.snmp_pdu_create(SNMP_MSG_TRAP2)

        # sysUpTime is mandatory on V2Traps.
        objid_sysuptime = mkoid((1,3,6,1,2,1,1,3,0))
        uptime = "%ld" % lib.get_uptime()
        lib.snmp_add_var(
            pdu, objid_sysuptime, len(objid_sysuptime), 't', uptime)

        # snmpTrapOID is mandatory on V2Traps.
        objid_snmptrap = mkoid((1,3,6,1,6,3,1,1,4,1,0))
        lib.snmp_add_var(
            pdu, objid_snmptrap, len(objid_snmptrap), 'o', trapoid)

        if varbinds:
            for n, t, v in varbinds:
                n = strToOid(n)
                lib.snmp_add_var(pdu, n, len(n), t, v)

        lib.snmp_send(self.sess, pdu)

    def close(self):
        if not self.sess: return
        if id(self) not in sessionMap:
            log.warn("Unable to find session id %r in sessionMap", self.kw)
            return
        lib.snmp_close(self.sess)
        del sessionMap[id(self)]
        self.args = None

    def callback(self, pdu):
        pass

    def timeout(self, reqid):
        pass

    def _create_request(self, packetType):
        return lib.snmp_pdu_create(packetType)

    def sget(self, oids):
        req = self._create_request(SNMP_MSG_GET)
        for oid in oids:
            oid = mkoid(oid)
            lib.snmp_add_null_var(req, oid, len(oid))
        response = netsnmp_pdu_p()
        if lib.snmp_synch_response(self.sess, req, byref(response)) == 0:
            result = dict(getResult(response.contents))
            lib.snmp_free_pdu(response)
            return result


    def _handle_send_status(self, req, send_status, send_type):
        if send_status == 0:
            cliberr = c_int()
            snmperr = c_int()
            errstring = c_char_p()
            lib.snmp_error(self.sess, byref(cliberr), byref(snmperr), byref(errstring));
            fmt = "Session.%s: snmp_send cliberr=%s, snmperr=%s, errstring=%s"
            msg = fmt % (send_type, cliberr.value, snmperr.value, errstring.value)
            log.debug(msg)
            lib.snmp_free_pdu(req)
            if snmperr.value == SNMPERR_TIMEOUT:
                raise SnmpTimeoutError()
            raise SnmpError(msg)

    def get(self, oids):
        req = self._create_request(SNMP_MSG_GET)
        for oid in oids:
            oid = mkoid(oid)
            lib.snmp_add_null_var(req, oid, len(oid))
        send_status = lib.snmp_send(self.sess, req)
        self._handle_send_status(req, send_status, 'get')
        return req.contents.reqid

    def getbulk(self, nonrepeaters, maxrepetitions, oids):
        req = self._create_request(SNMP_MSG_GETBULK)
        req = cast(req, POINTER(netsnmp_pdu))
        req.contents.errstat = nonrepeaters
        req.contents.errindex = maxrepetitions
        for oid in oids:
            oid = mkoid(oid)
            lib.snmp_add_null_var(req, oid, len(oid))
        send_status = lib.snmp_send(self.sess, req)
        self._handle_send_status(req, send_status, 'get')
        return req.contents.reqid

    def walk(self, root):
        req = self._create_request(SNMP_MSG_GETNEXT)
        oid = mkoid(root)
        lib.snmp_add_null_var(req, oid, len(oid))
        send_status = lib.snmp_send(self.sess, req)
        log.debug("Session.walk: send_status=%s" % send_status)
        self._handle_send_status(req, send_status, 'walk')
        return req.contents.reqid


MAXFD = 1024
fdset = c_int32 * (MAXFD/32)

class timeval(Structure):
    _fields_ = [
        ('tv_sec', c_long),
        ('tv_usec', c_long),
        ]

def fdset2list(rd, n):
    result = []
    for i in range(len(rd)):
        if rd[i]:
            for j in range(0, 32):
                bit = 0x00000001 << (j % 32)
                if rd[i] & bit:
                    result.append(i * 32 + j)
    return result

def snmp_select_info():
    rd = fdset()
    maxfd = c_int(0)
    timeout = timeval()
    timeout.tv_sec = 1
    timeout.tv_usec = 0
    block = c_int(0)
    maxfd = c_int(MAXFD)
    lib.snmp_select_info(byref(maxfd),
                             byref(rd),
                             byref(timeout),
                             byref(block))
    t = None
    if not block:
        t = timeout.tv_sec + timeout.tv_usec / 1e6
    return fdset2list(rd, maxfd.value), t

def snmp_read(fd):
    rd = fdset()
    rd[fd / 32] |= 1 << (fd % 32)
    lib.snmp_read(byref(rd))

done = False
def loop():
    while not done:
        from select import select
        rd, t = snmp_select_info()
        if t is None:
            break
        rd, w, x = select(rd, [], [], t)
        if rd:
            for r in rd:
                snmp_read(r)
        else:
            lib.snmp_timeout()

def stop():
    global done
    done = 1

