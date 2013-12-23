#!/usr/bin/env python
#######################################################
# Version: 01a Alpha02                                #
#  Status: Not Functional                             #
#   Notes: Converting to Python                       #
#  Zenoss: Core 4.2.4 & ZenPacks (v1897)              #
#      OS: Ubuntu/Debian x86_64 (requires 64-bit os)  #
#######################################################

import sys
import os
import time
import urllib

# Script variables
zenosshome="/home/zenoss"
downdir="/tmp"
varurl="https://raw.github.com/hydruid/zenoss/master/core-autodeploy/4.2.4/misc/variables.sh"

# Message
os.system('clear')
print "Welcome to the Zenoss 4.2.4 core-autodeploy script for Ubuntu and Debian!"
print "Blog Post: http://hydruid-blog.com/?p=241"
print "Notes: All feedback and suggestions are appreciated." 
time.sleep(5)

# OS Update
os.system('apt-get update && apt-get dist-upgrade -y && apt-get autoremove -y')

# Zenoss User
os.system('useradd -m -U -s /bin/bash zenoss')
with open(os.path.join(zenosshome, '.bashrc'), "a") as f:
    f.write("export ZENHOME=/usr/local/zenoss\nexport PYTHONPATH=/usr/local/zenoss/lib/python\nexport PATH=/usr/local/zenoss/bin:$PATH\nexport INSTANCE_HOME=$ZENHOME\nexport PATH=/opt/zenup/bin:$PATH")
if not os.path.exists(os.path.join(zenosshome, 'zenoss424-srpm_install')):
    os.makedirs(os.path.join(zenosshome, 'zenoss424-srpm_install'))
urllib.urlretrieve(varurl, os.path.join(zenosshome, "zenoss424-srpm_install/variables.sh"))


#. $zenosshome/zenoss424-srpm_install/variables.sh
#mkdir $ZENHOME && chown -cR zenoss:zenoss $ZENHOME


exit()
