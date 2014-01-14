#!/usr/bin/env python
#######################################################
# Version: 01a Alpha04                                       
#######################################################

# Script Variables
## Zenoss
ZENHOME="/usr/local/zenoss"
PYTHONPATH="/usr/local/zenoss/lib/python"
PATH="/usr/local/zenoss/bin:$PATH"
INSTANCE_HOME="$ZENHOME"
## Misc
ARCH=struct.calcsize("P") * 8
USER=os.getlogin()
UBUNTUPKGS=os.system('apt-get install rrdtool libmysqlclient-dev nagios-plugins erlang subversion autoconf swig unzip zip g++ libssl-dev maven libmaven-compiler-plugin-java build-essential libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev oracle-java7-installer python-twisted python-gnutls python-twisted-web python-samba libsnmp-base snmp-mibs-downloader bc rpm2cpio memcached libncurses5 libncurses5-dev libreadline6-dev libreadline6 librrd-dev python-setuptools python-dev erlang-nox python-mysqldb -y')
DEBIANPKGS=os.system('apt-get install rrdtool libmysqlclient-dev nagios-plugins erlang subversion autoconf swig unzip zip g++ libssl-dev maven libmaven-compiler-plugin-java build-essential libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev oracle-java7-installer python-twisted python-gnutls python-twisted-web python-samba libsnmp-base bc rpm2cpio memcached libncurses5 libncurses5-dev libreadline6-dev libreadline6 librrd-dev python-setuptools python-dev erlang-nox smistrip -y')
PKGFIX=os.system('apt-get -f install')

# Functions
def readfile(fname, txt):
    with open(fname) as dataf:
        return any(txt in line for line in dataf)

