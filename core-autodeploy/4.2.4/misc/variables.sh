#!/bin/bash
#######################################################
# Version: 02b                                        #
#######################################################

# Variables
INSTALLDIR="/home/zenoss/zenoss424-srpm_install"
ZENHOME=/usr/local/zenoss
PYTHONPATH=/usr/local/zenoss/lib/python
PATH=/usr/local/zenoss/bin:$PATH
INSTANCE_HOME=$ZENHOME

# Functions
detect-os () {
if grep -Fxq "Ubuntu 12.04.3 LTS" /etc/issue.net
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

