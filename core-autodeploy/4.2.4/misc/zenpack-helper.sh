#!/bin/bash
#######################################################
# Version: 01a                                        #
#######################################################

#!/bin/bash
ZENHOME=$ZENHOME
export ZENHOME=$ZENHOME
PYTHONPATH=$ZENHOME/lib/python
PATH=$ZENHOME/bin:$PATH
INSTANCE_HOME=$ZENHOME
$ZENHOME/bin/zenoss restart
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.PySamba-1.0.2-py2.7-linux-x86_64.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.WindowsMonitor-1.0.8-py2.7.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.ActiveDirectory-2.1.0-py2.7.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.ApacheMonitor-2.1.3-py2.7.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.DellMonitor-2.2.0-py2.7.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.DeviceSearch-1.2.0-py2.7.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.DigMonitor-1.1.0-py2.7.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.DnsMonitor-2.1.0-py2.7.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.EsxTop-1.1.0-py2.7.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.FtpMonitor-1.1.0-py2.7.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.HPMonitor-2.1.0-py2.7.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.HttpMonitor-2.1.0-py2.7.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.IISMonitor-2.0.2-py2.7.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.IRCDMonitor-1.1.0-py2.7.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.JabberMonitor-1.1.0-py2.7.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.LDAPMonitor-1.4.0-py2.7.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.LinuxMonitor-1.2.1-py2.7.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.MSExchange-2.0.4-py2.7.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.MSMQMonitor-1.2.1-py2.7.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.MSSQLServer-2.0.3-py2.7.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.MySqlMonitor-2.2.0-py2.7.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.NNTPMonitor-1.1.0-py2.7.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.NtpMonitor-2.2.0-py2.7.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.PythonCollector-1.0.1-py2.7.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.WBEM-1.0.0-py2.7.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.WindowsMonitor-1.0.8-py2.7.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.XenMonitor-1.1.0-py2.7.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.ZenJMX-3.9.5-py2.7.egg
zenpack --install /home/zenoss/zenoss424-srpm_install/rpm/ZenPacks.zenoss.ZenossVirtualHostMonitor-2.4.0-py2.7.egg
easy_install readline
$ZENHOME/bin/zenoss restart
