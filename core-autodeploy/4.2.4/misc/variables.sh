#!/bin/bash
#######################################################
# Version: 03e                                        #
#######################################################

### CURRENT SECTION ###
# Path Variables
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
	do case $opt in "Yes") echo "...continuing script with Non Supported OS...good luck!"
	break ;;
	"No") echo "...stopping script" && exit 0
	break ;; *) echo invalid option;; esac
	done }
supos="echo ...Supported OS detected."
detect-os () {
	if grep -q "Ubuntu 13" /etc/issue.net
		then    $supos && curos="ubuntu"
	elif grep -q "Ubuntu 12" /etc/issue.net
		then    $supos && curos="ubuntu"
	elif grep -Fxq "Debian GNU/Linux 7" /etc/issue.net
	then    $supos && curos="debian"
	else    menu-os
	fi      }


### LEGACY SECTION ###
# Path Variables
	#INSTALLDIR="/home/zenoss/zenoss424-srpm_install"

# Functions
detect-os2 () {
if grep -Fxq "Ubuntu 13.04" /etc/issue.net
        then    echo "...Supported OS detected."
elif grep -Fxq "Ubuntu 13.10" /etc/issue.net
       then    echo "...Supported OS detected."
elif grep -Fxq "Ubuntu 12.04.3 LTS" /etc/issue.net
       then    echo "...Supported OS detected."
else    menu-os
fi      }

detect-os3 () { 
if grep -Fxq "Debian GNU/Linux 7" /etc/issue.net
        then    echo "...Supported OS detected."
elif grep -Fxq "Debian GNU/Linux 6.0" /etc/issue.net
        then    echo "...Non Supported OS detected" && echo && echo "Notes: The python-samba package doesn't exist for Squeeze, and the Wheezy version requires a massive package upgrade to python2.7. Simply put it would be best to use Wheezy or newer!" && exit 0
else    menu-os
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

debian-testing-repo () {
cp /etc/apt/sources.list /etc/apt/sources.list.orig
wget -N https://raw.github.com/hydruid/zenoss/master/core-autodeploy/4.2.4/misc/debian-testing-repo.list -P /root/
mv /root/debian-testing-repo.list /etc/apt/sources.list
apt-get update
apt-get -t testing install libc6 libc6-dev -y
cp /etc/apt/sources.list.orig /etc/apt/sources.list
apt-get update
	}

give-props () {
apt-get install lynx -y 
lynx http://hydruid-blog.com/?cat=5 > /dev/null & echo
lynx http://hydruid-blog.com/?cat=5 > /dev/null & echo
lynx http://hydruid-blog.com/?cat=5 > /dev/null & echo
wget -N http://softlayer-dal.dl.sourceforge.net/project/zenoss/zenoss-4.2/zenoss-4.2.4/4.2.4-1897/zenoss_core-4.2.4-1897.el6.src.rpm -P ~zenoss/
killall lynx > /dev/null & echo
apt-get remove lynx -y > /dev/null & echo
        }

pkg-fix () {
apt-get -f install
        }

os-fixes () {
if grep -Fxq "Ubuntu 13.04" /etc/issue.net
        then    echo "...No specific OS fixes needed."
elif grep -Fxq "Ubuntu 13.10" /etc/issue.net
	then	cd /usr/local/zenoss/lib/python/pynetsnmp
		mv netsnmp.py netsnmp.py.orig
		wget https://raw.github.com/hydruid/zenoss/master/core-autodeploy/4.2.4/misc/netsnmp.py
		chown zenoss:zenoss netsnmp.py
		echo "...Specific OS fixes complete."
elif grep -Fxq "Ubuntu 12.04.3 LTS" /etc/issue.net
       then    echo "...No specific OS fixes needed."
fi      }
