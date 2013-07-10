#!/bin/bash
#
# Version: 05a - Beta02
# Status: Not functional...under heavy development
#
# Zenoss: Core 4.2.3 (From Subversion)
# OS: Ubuntu 12.04 x64
#

# Update package list and install any updates
echo "Step 01: Installing Ubuntu updates..."
apt-get update > /dev/null && apt-get dist-upgrade -y > /dev/null


# Verify OS/Arch compatibility, ensure not running as the 'zenoss' user
echo "Step 02: Run System Checks..."
if grep -Fxq "Ubuntu 12.04.2 LTS" /etc/issue.net
	then	echo "...Correct OS detected."
		if uname -m | grep -Fxq "x86_64"
			then	echo "...Correct Arch detected"
			else	echo "...Incorrect Arch detected...stopped script" && exit 0
                fi
	else	echo "...Incorrect OS detected...stopping script" && exit 0
fi
if [ `whoami` != 'zenoss' ]; then	echo "...All system checks passed"
	else	echo "...This script should not be ran by the zenoss user" && exit 0
fi


# Install required packages
echo "Step 03: Install Dependencies"
apt-get install python-software-properties -y && echo | add-apt-repository ppa:webupd8team/java
apt-get update && apt-get install rrdtool mysql-server mysql-client mysql-common libmysqlclient-dev rabbitmq-server nagios-plugins erlang subversion autoconf swig unzip zip g++ libssl-dev maven libmaven-compiler-plugin-java build-essential libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev oracle-java6-installer python-twisted python-gnutls python-twisted-web python-samba libsnmp-base snmp-mibs-downloader bc rpm2cpio memcached libncurses5 libncurses5-dev libreadline6-dev libreadline6 -y


# Setup the 'zenoss' user, configure rabbit, apply misc. adjustments 
echo "Step 04: Zenoss user setup and misc package adjustments"
useradd -m -U -s /bin/bash zenoss > /dev/null
mkdir /usr/local/zenoss > /dev/null
chown -R zenoss:zenoss /usr/local/zenoss
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


# Download the zenoss source 
echo "Step 05: Download the Zenoss install"
svn co http://dev.zenoss.org/svn/tags/zenoss-4.2.3/inst /home/zenoss/zenoss-inst
chown -R zenoss:zenoss /home/zenoss/zenoss-inst



#easy_install readline

