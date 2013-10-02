#!/bin/bash
#######################################################
# Version: 02f                                        #
#######################################################

# Variables
INSTALLDIR="/home/zenoss/zenoss424-srpm_install"
export ZENHOME=/usr/local/zenoss
export PYTHONPATH=/usr/local/zenoss/lib/python
export PATH=/usr/local/zenoss/bin:$PATH
export INSTANCE_HOME=$ZENHOME

# Functions
menu-os () {
echo && echo "...Non Supported OS detected...would you like to continue anyways?"
PS3='(Press 1 or 2): '
options=("Yes" "No")
select opt in "${options[@]}"
do
case $opt in
"Yes")
echo "...continuing script with Non Supported OS...good luck!"
break
;;
"No")
echo "...stopping script" && exit 0
break
;;
        *) echo invalid option;;
esac
done } 
detect-os () {
if grep -Fxq "Ubuntu 12.04.3 LTS" /etc/issue.net
        then    echo "...Supported OS detected."
        else    echo "...Non Supported OS detected...stopping script" && exit 0
fi	}
detect-os2 () {
if grep -Fxq "Ubuntu 13.04" /etc/issue.net
        then    echo "...Supported OS detected."
        else    echo " "
                if grep -Fxq "Ubuntu 12.04.3 LTS" /etc/issue.net
                        then    echo "...Supported OS detected."
                        else    echo "...Non Supported OS detected...stopping script" && exit 0
                fi
fi      }
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
