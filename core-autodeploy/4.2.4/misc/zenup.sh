#!/bin/bash
#######################################################
# Version: 01a Alpha - 01                             #
# Notes: Not Functional...                            #
#######################################################

wget -N http://wiki.zenoss.org/download/core/zenup/zenup-1.0.0.131-1.el6.x86_64.rpm
rpm2cpio zenup-1.0.0.131-1.el6.x86_64.rpm | cpio -i --make-directories
wget -N http://wiki.zenoss.org/download/core/zenup/zenoss_core-4.2.4.el6-pristine.tgz
wget -N http://wiki.zenoss.org/download/core/zenup/zenoss_core-4.2.4-SP71.zup
