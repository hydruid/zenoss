#!/bin/bash

#####################################################
# Version: 03                                        #
# Status: Functional...still in testing              #
#                                                    #
# Zenoss Version: Core ZenPacks for 4.2.3            #
# OS: Ubuntu 12.04 x64                               #
######################################################

#Step-01: Download and install the Core Zenpacks             
declare -a arr=(ZenPacks.zenoss.PySamba ZenPacks.zenoss.WindowsMonitor ZenPacks.zenoss.ActiveDirectory ZenPacks.zenoss.ApacheMonitor ZenPacks.zenoss.DellMonitor ZenPacks.zenoss.DeviceSearch ZenPacks.zenoss.DigMonitor ZenPacks.zenoss.DnsMonitor ZenPacks.zenoss.FtpMonitor ZenPacks.zenoss.HPMonitor ZenPacks.zenoss.HttpMonitor ZenPacks.zenoss.IISMonitor ZenPacks.zenoss.IRCDMonitor ZenPacks.zenoss.JabberMonitor ZenPacks.zenoss.LDAPMonitor ZenPacks.zenoss.LinuxMonitor ZenPacks.zenoss.ZenossVirtualHostMonitor ZenPacks.zenoss.MSExchange ZenPacks.zenoss.MSMQMonitor ZenPacks.zenoss.MySqlMonitor ZenPacks.zenoss.MSSQLServer ZenPacks.zenoss.NNTPMonitor ZenPacks.zenoss.NtpMonitor ZenPacks.zenoss.ZenAWS ZenPacks.zenoss.ZenJMX)
for i in ${arr[@]}
do
zenpack --fetch $i
done

#Step-02: Restart Zenoss
zenoss restart
