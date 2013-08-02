#!/bin/bash
#######################################################
# Version: 02a                                        #
#######################################################

INSTALLDIR="/home/zenoss/zenoss424-srpm_install"
QUIET="> /dev/null 2>/dev/null"


export ZENHOME=/usr/local/zenoss
export PYTHONPATH=/usr/local/zenoss/lib/python
export PATH=/usr/local/zenoss/bin:$PATH
export INSTANCE_HOME=$ZENHOME

