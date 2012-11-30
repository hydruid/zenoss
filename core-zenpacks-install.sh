#!/bin/bash
###########################################################
#
# A simple script to auto-install Zenoss Core 4.2 ZenPacks
#
# This script should be run on a base install of
# Ubuntu 12.04 x64
#
# Status: Still Testing...run twice to resolve dependencies
# Version: 01-Beta01
#
###########################################################


echo "Zenpack Core"
echo "#Zenpack Directory: http://zenpacks.zenoss.com/pypi/none/4.2/ "
if [ -f ZenPacks.zenoss.ZenJMX-3.8.0-py2.7.egg ];
	then
		zenpack --install ZenPacks.zenoss.PySamba-1.0.0-py2.7-linux-x86_64.egg
		zenpack --install ZenPacks.zenoss.WindowsMonitor-1.0.2-py2.7.egg
		zenpack --install ZenPacks.zenoss.ActiveDirectory-2.1.0-py2.7.egg
		zenpack --install ZenPacks.zenoss.ApacheMonitor-2.1.3-py2.7.egg
		zenpack --install ZenPacks.zenoss.DellMonitor-2.2.0-py2.7.egg
		zenpack --install ZenPacks.zenoss.DeviceSearch-1.2.0-py2.7.egg
		zenpack --install ZenPacks.zenoss.DigMonitor-1.0.3-py2.7.egg
		zenpack --install ZenPacks.zenoss.DnsMonitor-2.0.3-py2.7.egg	
		zenpack --install ZenPacks.zenoss.EsxTop-1.0.3-py2.7.egg
		zenpack --install ZenPacks.zenoss.FtpMonitor-1.0.3-py2.7.egg
		zenpack --install ZenPacks.zenoss.HPMonitor-2.1.0-py2.7.egg
		zenpack --install ZenPacks.zenoss.HttpMonitor-2.0.5-py2.7.egg
		zenpack --install ZenPacks.zenoss.IISMonitor-2.0.2-py2.7.egg
		zenpack --install ZenPacks.zenoss.IRCDMonitor-1.0.3-py2.7.egg
		zenpack --install ZenPacks.zenoss.JabberMonitor-1.0.3-py2.7.egg
		zenpack --install ZenPacks.zenoss.LDAPMonitor-1.3.0-py2.7.egg
		zenpack --install ZenPacks.zenoss.LinuxMonitor-1.2.0-py2.7.egg
		zenpack --install ZenPacks.zenoss.ZenossVirtualHostMonitor-2.4.0-py2.7.egg
		zenpack --install ZenPacks.zenoss.MSExchange-2.0.4-py2.7.egg
		zenpack --install ZenPacks.zenoss.MSMQMonitor-1.2.1-py2.7.egg
		zenpack --install ZenPacks.zenoss.MySqlMonitor-2.2.0-py2.7.egg
		zenpack --install ZenPacks.zenoss.MSSQLServer-2.0.3-py2.7.egg
		zenpack --install ZenPacks.zenoss.NNTPMonitor-1.0.3-py2.7.egg
		zenpack --install ZenPacks.zenoss.NtpMonitor-2.0.4-py2.7.egg
		zenpack --install ZenPacks.zenoss.RPCMonitor-1.0.3-py2.7.egg
		zenpack --install ZenPacks.zenoss.XenMonitor-1.1.0-py2.7.egg
		zenpack --install ZenPacks.zenoss.ZenAWS-1.0.7-py2.7.egg
		zenpack --install ZenPacks.zenoss.ZenJMX-3.8.0-py2.7.egg 
	else
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.PySamba-1.0.0-py2.7-linux-x86_64.egg
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.WindowsMonitor-1.0.2-py2.7.egg
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.ActiveDirectory-2.1.0-py2.7.egg
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.ApacheMonitor-2.1.3-py2.7.egg
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.DellMonitor-2.2.0-py2.7.egg
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.DeviceSearch-1.2.0-py2.7.egg
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.DigMonitor-1.0.3-py2.7.egg
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.DnsMonitor-2.0.3-py2.7.egg	
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.EsxTop-1.0.3-py2.7.egg
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.FtpMonitor-1.0.3-py2.7.egg
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.HPMonitor-2.1.0-py2.7.egg
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.HttpMonitor-2.0.5-py2.7.egg
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.IISMonitor-2.0.2-py2.7.egg
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.IRCDMonitor-1.0.3-py2.7.egg
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.JabberMonitor-1.0.3-py2.7.egg
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.LDAPMonitor-1.3.0-py2.7.egg
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.LinuxMonitor-1.2.0-py2.7.egg
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.ZenossVirtualHostMonitor-2.4.0-py2.7.egg
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.MSExchange-2.0.4-py2.7.egg
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.MSMQMonitor-1.2.1-py2.7.egg
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.MySqlMonitor-2.2.0-py2.7.egg
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.MSSQLServer-2.0.3-py2.7.egg
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.NNTPMonitor-1.0.3-py2.7.egg
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.NtpMonitor-2.0.4-py2.7.egg
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.RPCMonitor-1.0.3-py2.7.egg
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.XenMonitor-1.1.0-py2.7.egg
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.ZenAWS-1.0.7-py2.7.egg
		wget http://zenpacks.zenoss.com/pypi/eggs/none/ZenPacks.zenoss.ZenJMX-3.8.0-py2.7.egg
		zenpack --install ZenPacks.zenoss.PySamba-1.0.0-py2.7-linux-x86_64.egg
		zenpack --install ZenPacks.zenoss.WindowsMonitor-1.0.2-py2.7.egg
		zenpack --install ZenPacks.zenoss.ActiveDirectory-2.1.0-py2.7.egg
		zenpack --install ZenPacks.zenoss.ApacheMonitor-2.1.3-py2.7.egg
		zenpack --install ZenPacks.zenoss.DellMonitor-2.2.0-py2.7.egg
		zenpack --install ZenPacks.zenoss.DeviceSearch-1.2.0-py2.7.egg
		zenpack --install ZenPacks.zenoss.DigMonitor-1.0.3-py2.7.egg
		zenpack --install ZenPacks.zenoss.DnsMonitor-2.0.3-py2.7.egg	
		zenpack --install ZenPacks.zenoss.EsxTop-1.0.3-py2.7.egg
		zenpack --install ZenPacks.zenoss.FtpMonitor-1.0.3-py2.7.egg
		zenpack --install ZenPacks.zenoss.HPMonitor-2.1.0-py2.7.egg
		zenpack --install ZenPacks.zenoss.HttpMonitor-2.0.5-py2.7.egg
		zenpack --install ZenPacks.zenoss.IISMonitor-2.0.2-py2.7.egg
		zenpack --install ZenPacks.zenoss.IRCDMonitor-1.0.3-py2.7.egg
		zenpack --install ZenPacks.zenoss.JabberMonitor-1.0.3-py2.7.egg
		zenpack --install ZenPacks.zenoss.LDAPMonitor-1.3.0-py2.7.egg
		zenpack --install ZenPacks.zenoss.LinuxMonitor-1.2.0-py2.7.egg
		zenpack --install ZenPacks.zenoss.ZenossVirtualHostMonitor-2.4.0-py2.7.egg
		zenpack --install ZenPacks.zenoss.MSExchange-2.0.4-py2.7.egg
		zenpack --install ZenPacks.zenoss.MSMQMonitor-1.2.1-py2.7.egg
		zenpack --install ZenPacks.zenoss.MySqlMonitor-2.2.0-py2.7.egg
		zenpack --install ZenPacks.zenoss.MSSQLServer-2.0.3-py2.7.egg
		zenpack --install ZenPacks.zenoss.NNTPMonitor-1.0.3-py2.7.egg
		zenpack --install ZenPacks.zenoss.NtpMonitor-2.0.4-py2.7.egg
		zenpack --install ZenPacks.zenoss.RPCMonitor-1.0.3-py2.7.egg
		zenpack --install ZenPacks.zenoss.XenMonitor-1.1.0-py2.7.egg
		zenpack --install ZenPacks.zenoss.ZenAWS-1.0.7-py2.7.egg
		zenpack --install ZenPacks.zenoss.ZenJMX-3.8.0-py2.7.egg
fi