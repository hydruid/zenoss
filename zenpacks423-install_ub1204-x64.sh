#!/bin/bash

#####################################################
# Version: 05b                                       #
# Status: Functional...still in testing              #
#                                                    #
# Zenoss Version: Core ZenPacks for 4.2.3            #
# OS: Ubuntu 12.04 x64                               #
######################################################

#Step-01
if whoami | grep zenoss
    then
        echo ""
    else
        echo "This script should be ran as the zenoss user..."
        echo "It's also recommended to run from /home/zenoss"
        exit 0
fi

#Step-02: Verify zenoss is running
zenoss restart

#Step-03: Download and install the Core Zenpacks
wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.PySamba-1.0.0-py2.7-linux-x86_64.egg
zenpack --install ZenPacks.zenoss.PySamba-1.0.0-py2.7-linux-x86_64.egg
declare -a arr=(ZenPacks.zenoss.WindowsMonitor ZenPacks.zenoss.ActiveDirectory ZenPacks.zenoss.ApacheMonitor ZenPacks.zenoss.DellMonitor ZenPacks.zenoss.DeviceSearch ZenPacks.zenoss.DigMonitor ZenPacks.zenoss.DnsMonitor ZenPacks.zenoss.FtpMonitor ZenPacks.zenoss.HPMonitor ZenPacks.zenoss.HttpMonitor ZenPacks.zenoss.IISMonitor ZenPacks.zenoss.IRCDMonitor ZenPacks.zenoss.JabberMonitor ZenPacks.zenoss.LDAPMonitor ZenPacks.zenoss.LinuxMonitor ZenPacks.zenoss.ZenossVirtualHostMonitor ZenPacks.zenoss.MSExchange ZenPacks.zenoss.MSMQMonitor ZenPacks.zenoss.MySqlMonitor ZenPacks.zenoss.MSSQLServer ZenPacks.zenoss.NNTPMonitor ZenPacks.zenoss.NtpMonitor ZenPacks.zenoss.ZenAWS ZenPacks.zenoss.ZenJMX)
for i in ${arr[@]}
do
zenpack --fetch $i
done

#Step04: Apply PySamba, ZenWinPerf, and Easy-Install adjustments
wget https://dl.dropbox.com/s/mbgu0x9fyxhusnv/pysamba.zip
unzip pysamba.zip
cp -fr pysamba /usr/local/zenoss/ZenPacks/ZenPacks.zenoss.PySamba-1.0.0-py2.7-linux-x86_64.egg/ZenPacks/zenoss/PySamba/lib
cp -fr pysamba /usr/local/zenoss/ZenPacks/ZenPacks.zenoss.PySamba-1.0.0-py2.7.egg/ZenPacks/zenoss/PySamba/lib

touch /usr/local/zenoss/etc/zenwinperf.conf
wget https://dl.dropbox.com/s/p6s4adtpdjibmcl/easy-install.pth
cp easy-install.pth /usr/local/zenoss/ZenPacks

#Step-05: Restart Zenoss
zenoss restart
