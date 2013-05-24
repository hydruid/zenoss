#!/bin/bash
#
# Version: 04a
# Status: Functional...complete rebuild, still needs lost of testing
#
# Zenoss: Core 4.2.3
# OS: Ubuntu 12.04 x64
#

echo "Step 01: Installing Ubuntu updates..."
	apt-get update > /dev/null
	apt-get dist-upgrade -y > /dev/null

echo "Step 02: Determine OS and Arch..."
	if grep -Fxq "Ubuntu 12.04.2 LTS" /etc/issue.net
	then
		echo "     Correct OS detected."
	else
		echo "     Incorrect OS detected...stopping script"
		exit 0
	fi
	if uname -m | grep -Fxq "x86_64"
	then
		echo "     Correct Arch detected."
	else
		echo "     Incorrect Arch detected...stopping script"
		exit 0
	fi

echo "Step 03: Check user"
	if whoami | grep zenoss
	then
		echo "This script should not be ran as the zenoss user..."
		echo "You should run it as your normal admin user..."
		exit 0
	else
		echo "     Pass...user is not 'zenoss'."
	fi

echo "Step 04: Install Dependencies"
sudo apt-get install python-software-properties -y
echo | add-apt-repository ppa:webupd8team/java
apt-get update > /dev/null
apt-get install rrdtool mysql-server mysql-client mysql-common libmysqlclient-dev rabbitmq-server nagios-plugins erlang subversion autoconf swig unzip zip g++ libssl-dev maven libmaven-compiler-plugin-java build-essential libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev oracle-java6-installer python-twisted python-gnutls python-twisted-web python-samba libsnmp-base snmp-mibs-downloader bc rpm2cpio -y

echo "Step 05: Zenoss user setup"
	if [ -f /home/zenoss/.bashrc ];
	then
		echo "     Zenoss user already exists...skipping"
	else
		useradd -m -U -s /bin/bash zenoss
		mkdir /usr/local/zenoss
		chown -R zenoss:zenoss /usr/local/zenoss
		rabbitmqctl add_user zenoss zenoss
		rabbitmqctl add_vhost /zenoss
		rabbitmqctl set_permissions -p /zenoss zenoss '.*' '.*' '.*'
		chmod 777 /home/zenoss/.bashrc
		echo 'export ZENHOME=/usr/local/zenoss' >> /home/zenoss/.bashrc
		echo 'export PYTHONPATH=/usr/local/zenoss/lib/python' >> /home/zenoss/.bashrc
		echo 'export PATH=/usr/local/zenoss/bin:$PATH' >> /home/zenoss/.bashrc
		echo 'export INSTANCE_HOME=$ZENHOME' >> /home/zenoss/.bashrc
		chmod 644 /home/zenoss/.bashrc
	fi

echo "Step 06: Apply Misc. Adjustments for MySQL, SNMP, and Java"
	echo '#max_allowed_packet=16M' >> /etc/mysql/my.cnf
	echo 'innodb_buffer_pool_size=256M' >> /etc/mysql/my.cnf
	echo 'innodb_additional_mem_pool_size=20M' >> /etc/mysql/my.cnf
	sed -i 's/mibs/#mibs/g' /etc/snmp/snmp.conf


echo "Step 07: Download the Zenoss install"
		sudo svn --quiet co http://dev.zenoss.org/svn/tags/zenoss-4.2.3/inst /home/zenoss/zenoss-inst
		sudo chown -R zenoss:zenoss /home/zenoss/zenoss-inst

echo "Step 08: Start the Zenoss install"
	if [ -f /home/zenoss/helper1.sh ];
	then
		rm /home/zenoss/helper1.sh
		touch /home/zenoss/helper1.sh
	else
		touch /home/zenoss/helper1.sh
	fi
	echo '#!/bin/bash' >> /home/zenoss/helper1.sh
	echo 'ZENHOME=/usr/local/zenoss' >> /home/zenoss/helper1.sh
	echo 'PYTHONPATH=/usr/local/zenoss/lib/python' >> /home/zenoss/helper1.sh
	echo 'PATH=/usr/local/zenoss/bin:$PATH' >> /home/zenoss/helper1.sh
	echo 'INSTANCE_HOME=$ZENHOME' >> /home/zenoss/helper1.sh
	echo 'cd /home/zenoss/zenoss-inst' >> /home/zenoss/helper1.sh
	echo './install.sh' >> /home/zenoss/helper1.sh
	su - zenoss -c "/bin/sh /home/zenoss/helper1.sh"
	
echo "Step 09: Install the Core ZenPacks"
	if [ -f /home/zenoss/ZenPacks.zenoss.PySamba-1.0.0-py2.7-linux-x86_64.egg ];
	then
		echo "     ZenPacks already in /home/zenoss..."
		echo "     Skipping ZenPack download..."
	else
		echo "     Downloading RPM to extract the ZenPacks..."
		wget http://iweb.dl.sourceforge.net/project/zenoss/zenoss-4.2/zenoss-4.2.3/zenoss_core-4.2.3.el6.x86_64.rpm
		mkdir /home/zenoss/rpm
		mv zenoss_core-4.2.3.el6.x86_64.rpm /home/zenoss/rpm
		cd /home/zenoss/rpm
		rpm2cpio zenoss_core-4.2.3.el6.x86_64.rpm | sudo cpio -ivd ./opt/zenoss/packs/*.*
		cp /home/zenoss/rpm/opt/zenoss/packs/*.egg /home/zenoss/
	fi
        chown -R zenoss:zenoss /home/zenoss
		
	if [ -f /home/zenoss/helper2.sh ];
	then
		rm /home/zenoss/helper2.sh
		touch /home/zenoss/helper2.sh
	else
		touch /home/zenoss/helper2.sh
	fi
	echo '#!/bin/bash' >> /home/zenoss/helper2.sh
	echo 'ZENHOME=/usr/local/zenoss' >> /home/zenoss/helper2.sh
	echo 'export ZENHOME=/usr/local/zenoss' >> /home/zenoss/helper2.sh
	echo 'PYTHONPATH=/usr/local/zenoss/lib/python' >> /home/zenoss/helper2.sh
	echo 'PATH=/usr/local/zenoss/bin:$PATH' >> /home/zenoss/helper2.sh
	echo 'INSTANCE_HOME=$ZENHOME' >> /home/zenoss/helper2.sh
	echo '/usr/local/zenoss/bin/zenoss restart' >> /home/zenoss/helper2.sh
	echo 'zenpack --install ZenPacks.zenoss.PySamba-1.0.0-py2.7-linux-x86_64.egg' >> /home/zenoss/helper2.sh
	echo 'zenpack --install ZenPacks.zenoss.WindowsMonitor-1.0.5-py2.7.egg' >> /home/zenoss/helper2.sh
	echo 'zenpack --install ZenPacks.zenoss.ActiveDirectory-2.1.0-py2.7.egg' >> /home/zenoss/helper2.sh
	echo 'zenpack --install ZenPacks.zenoss.ApacheMonitor-2.1.3-py2.7.egg' >> /home/zenoss/helper2.sh
	echo 'zenpack --install ZenPacks.zenoss.DellMonitor-2.2.0-py2.7.egg' >> /home/zenoss/helper2.sh
	echo 'zenpack --install ZenPacks.zenoss.DeviceSearch-1.2.0-py2.7.egg' >> /home/zenoss/helper2.sh
	echo 'zenpack --install ZenPacks.zenoss.DigMonitor-1.1.0-py2.7.egg' >> /home/zenoss/helper2.sh
	echo 'zenpack --install ZenPacks.zenoss.DnsMonitor-2.1.0-py2.7.egg' >> /home/zenoss/helper2.sh
	echo 'zenpack --install ZenPacks.zenoss.EsxTop-1.1.0-py2.7.egg' >> /home/zenoss/helper2.sh
	echo 'zenpack --install ZenPacks.zenoss.FtpMonitor-1.1.0-py2.7.egg' >> /home/zenoss/helper2.sh
	echo 'zenpack --install ZenPacks.zenoss.HPMonitor-2.1.0-py2.7.egg' >> /home/zenoss/helper2.sh
	echo 'zenpack --install ZenPacks.zenoss.HttpMonitor-2.1.0-py2.7.egg' >> /home/zenoss/helper2.sh
	echo 'zenpack --install ZenPacks.zenoss.IISMonitor-2.0.2-py2.7.egg' >> /home/zenoss/helper2.sh
	echo 'zenpack --install ZenPacks.zenoss.IRCDMonitor-1.1.0-py2.7.egg' >> /home/zenoss/helper2.sh
	echo 'zenpack --install ZenPacks.zenoss.JabberMonitor-1.1.0-py2.7.egg' >> /home/zenoss/helper2.sh
	echo 'zenpack --install ZenPacks.zenoss.LDAPMonitor-1.4.0-py2.7.egg' >> /home/zenoss/helper2.sh
	echo 'zenpack --install ZenPacks.zenoss.LinuxMonitor-1.2.0-py2.7.egg' >> /home/zenoss/helper2.sh
	echo 'zenpack --install ZenPacks.zenoss.ZenossVirtualHostMonitor-2.4.0-py2.7.egg' >> /home/zenoss/helper2.sh
	echo 'zenpack --install ZenPacks.zenoss.MSExchange-2.0.4-py2.7.egg' >> /home/zenoss/helper2.sh
	echo 'zenpack --install ZenPacks.zenoss.MSMQMonitor-1.2.1-py2.7.egg' >> /home/zenoss/helper2.sh
	echo 'zenpack --install ZenPacks.zenoss.MySqlMonitor-2.2.0-py2.7.egg' >> /home/zenoss/helper2.sh
	echo 'zenpack --install ZenPacks.zenoss.MSSQLServer-2.0.3-py2.7.egg' >> /home/zenoss/helper2.sh
	echo 'zenpack --install ZenPacks.zenoss.NNTPMonitor-1.1.0-py2.7.egg' >> /home/zenoss/helper2.sh
	echo 'zenpack --install ZenPacks.zenoss.NtpMonitor-2.2.0-py2.7.egg' >> /home/zenoss/helper2.sh
	echo 'zenpack --install ZenPacks.zenoss.XenMonitor-1.1.0-py2.7.egg' >> /home/zenoss/helper2.sh
	echo 'zenpack --install ZenPacks.zenoss.ZenAWS-1.1.0-py2.7.egg' >> /home/zenoss/helper2.sh
	echo 'zenpack --install ZenPacks.zenoss.ZenJMX-3.9.3-py2.7.egg' >> /home/zenoss/helper2.sh
	echo '/usr/local/zenoss/bin/zenoss restart' >> /home/zenoss/helper2.sh
	su - zenoss -c "/bin/sh /home/zenoss/helper2.sh"

echo "Step 10: Post Installation Adjustments"
	chown root:zenoss /usr/local/zenoss/bin/nmap
	chmod u+s /usr/local/zenoss/bin/nmap
	chown root:zenoss /usr/local/zenoss/bin/zensocket
	chmod u+s /usr/local/zenoss/bin/zensocket
	chown root:zenoss /usr/local/zenoss/bin/pyraw
	chmod u+s /usr/local/zenoss/bin/pyraw
	echo 'watchdog True' >> /usr/local/zenoss/etc/zenwinperf.conf
	echo "     The Zenoss Install Script is Complete......browse to http://your-server-ip:8080"
