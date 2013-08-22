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
detectos () {
if grep -Fxq "Ubuntu 12.04.3 LTS" /etc/issue.net
        then    echo "...Correct OS detected."
        else    echo "...Incorrect OS detected...stopping script" && exit 0
fi
}
