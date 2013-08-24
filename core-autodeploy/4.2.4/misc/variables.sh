#!/bin/bash
#######################################################
# Version: 02d                                        #
#######################################################

# Variables
INSTALLDIR="/home/zenoss/zenoss424-srpm_install"
export ZENHOME=/usr/local/zenoss
export PYTHONPATH=/usr/local/zenoss/lib/python
export PATH=/usr/local/zenoss/bin:$PATH
export INSTANCE_HOME=$ZENHOME

# Functions
detect-os () {
if grep -Fxq "Ubuntu 12.04.3 LTS" /etc/issue.net
        then    echo "...Correct OS detected."
        else    echo "...Incorrect OS detected...stopping script" && exit 0
fi	}
detect-os2 () {
if grep -Fxq "Ubuntu 13.04" /etc/issue.net
        then    echo "...Correct OS detected."
        else    echo "...Incorrect OS detected...stopping script" && exit 0
fi	}
detect-arch () {
if uname -m | grep -Fxq "x86_64"
        then    echo "...Correct Arch detected."
        else    echo "...Incorrect Arch detected...stopped script" && exit 0
fi	}
detect-user () {
if [ `whoami` != 'zenoss' ];
        then    echo "...All system checks passed."
        else    echo "...This script should not be ran by the zenoss user" && exit 0
fi	}
mysql-conn_test () {
mysql -u root -e "show databases;" > /tmp/mysql.txt 2>> /tmp/mysql.txt
if grep -Fxq "Database" /tmp/mysql.txt
        then    echo "...MySQL connection test successful."
        else    echo "...Mysql connection failed...make sure the password is blank for the root MySQL user." && exit 0
fi	}
