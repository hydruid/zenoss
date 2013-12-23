#!/usr/bin/env python
#######################################################
# Version: 01a Alpha01                                #
#  Status: Not Functional                             #
#   Notes: Converting to Python                       #
#  Zenoss: Core 4.2.4 & ZenPacks (v1897)              #
#      OS: Ubuntu/Debian x86_64 (requires 64-bit os)  #
#######################################################

import os
import time

# Script variables
zenosshome="/home/zenoss"
downdir="/tmp"

os.system('clear')
print "Welcome to the Zenoss 4.2.4 core-autodeploy script for Ubuntu and Debian!"
print "Blog Post: http://hydruid-blog.com/?p=241"
print "Notes: All feedback and suggestions are appreciated." 
time.sleep(5)

os.system('apt-get update && apt-get dist-upgrade -y && apt-get autoremove -y')




exit()
