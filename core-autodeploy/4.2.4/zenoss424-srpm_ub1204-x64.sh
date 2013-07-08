#!/bin/bash
#
# Version: 01a
# Status: Not functional...under heavy development
#
# Zenoss: Core 4.2.4 Beta
# OS: Ubuntu 12.04 x64
#

# Update package list and install any updates
echo "Step 01: Install Ubuntu Updates..."
	apt-get update && apt-get dist-upgrade -y


# Verify OS/Arch compatibility, ensure not running as the 'zenoss' user
echo "Step 02: Run System Checks..."
	if grep -Fxq "Ubuntu 12.04.2 LTS" /etc/issue.net
	then
		echo "...Correct OS detected."
		if uname -m | grep -Fxq "x86_64"
			then
				echo "...Correct Arch detected"
			else
				echo "...Incorrect Arch detected...stopped script" && exit 0
		fi
	else
		echo "...Incorrect OS detected...stopping script" && exit 0 
	fi
	if whoami | grep zenoss
	then
		echo "...This script should not be ran as the zenoss user\n....You should run it as your normal admin user" && exit 0
	else
		echo "...All system checks passed"
	fi


# Install required packages
echo "Step 03: Install Dependencies"
	apt-get install python-software-properties -y && echo | add-apt-repository ppa:webupd8team/java
	apt-get update && apt-get install rrdtool mysql-server mysql-client mysql-common libmysqlclient-dev rabbitmq-server nagios-plugins erlang subversion autoconf swig unzip zip g++ libssl-dev maven libmaven-compiler-plugin-java build-essential libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev oracle-java6-installer python-twisted python-gnutls python-twisted-web python-samba libsnmp-base snmp-mibs-downloader bc rpm2cpio memcached -y


# Add the zenoss user, configure rabbit, and apply misc. package adjustments
echo "Step 04: Zenoss user setup"
	useradd -m -U -s /bin/bash zenoss > /dev/null
	mkdir /usr/local/zenoss > /dev/null
	chown -R zenoss:zenoss /usr/local/zenoss > /dev/null
	rabbitmqctl add_user zenoss zenoss > /dev/null
	rabbitmqctl add_vhost /zenoss > /dev/null
	rabbitmqctl set_permissions -p /zenoss zenoss '.*' '.*' '.*' > /dev/null
	chmod 777 /home/zenoss/.bashrc
	echo 'export ZENHOME=/usr/local/zenoss' >> /home/zenoss/.bashrc
	echo 'export PYTHONPATH=/usr/local/zenoss/lib/python' >> /home/zenoss/.bashrc
	echo 'export PATH=/usr/local/zenoss/bin:$PATH' >> /home/zenoss/.bashrc
	echo 'export INSTANCE_HOME=$ZENHOME' >> /home/zenoss/.bashrc
	chmod 644 /home/zenoss/.bashrc
	echo '#max_allowed_packet=16M' >> /etc/mysql/my.cnf
	echo 'innodb_buffer_pool_size=256M' >> /etc/mysql/my.cnf
	echo 'innodb_additional_mem_pool_size=20M' >> /etc/mysql/my.cnf
	sed -i 's/mibs/#mibs/g' /etc/snmp/snmp.conf


# Download the SRPM, extract the contents
echo "Step 05: Download the Zenoss install"
	mkdir /home/zenoss/zenoss-srpm_install
	cd /home/zenoss/zenoss-srpm_install
	wget http://iweb.dl.sourceforge.net/project/zenoss/zenoss-beta/builds/4.2.4-1856/zenoss_core-4.2.4-1856.el6.src.rpm
	rpm2cpio zenoss_core-4.2.4-1856.el6.src.rpm | cpio -i --make-directories
	bunzip2 zenoss_core-4.2.4-1856.el6.x86_64.tar.bz2
	tar -xvf zenoss_core-4.2.4-1856.el6.x86_64.tar
