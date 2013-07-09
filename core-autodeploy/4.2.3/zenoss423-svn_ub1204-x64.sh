#!/bin/bash
#
# Version: 05a
# Status: Not functional...under heavy development
#
# Zenoss: Core 4.2.3 (From Subversion)
# OS: Ubuntu 12.04 x64
#

# Update package list and install any updates
echo "Step 01: Installing Ubuntu updates..."
#apt-get update > /dev/null && apt-get dist-upgrade -y > /dev/null


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

#easy_install readline

