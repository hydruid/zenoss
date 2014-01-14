#!/usr/bin/env python
#######################################################
# Version: 01a Alpha04
#  Status: Not Functional                             
#   Notes: Converting to Python                       
#  Zenoss: Core 4.2.4 & ZenPacks (v1897)              
#      OS: Ubuntu/Debian x86_64 (requires 64-bit os) 
#######################################################

import sys
import os
import time
import urllib
import pwd
import grp
import struct

# Script variables
zenosshome="/home/zenoss"
downdir="/tmp"
varurl="https://raw.github.com/hydruid/zenoss/master/core-autodeploy/4.2.4/dev/variables.py"
zenuid=pwd.getpwnam("zenoss").pw_uid
zengid=grp.getgrnam("zenoss").gr_gid
MYSQLUSER="root"
MYSQLPASSWORD=""

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
urllib.urlretrieve(varurl, os.path.join(zenosshome, "zenoss424-srpm_install/variables.py"))
execfile("/home/zenoss/zenoss424-srpm_install/variables.py")
if not os.path.exists(ZENHOME):
    os.makedirs(ZENHOME)
os.chown(ZENHOME, zenuid, zengid)

# OS Compatibility Tests
if readfile('/etc/issue.net', 'Ubuntu 13'):
    print "...Supported OS detected"
    OS="ubuntu"
elif readfile('/etc/issue.net', 'Ubuntu 12'):
    print "...Supported OS detected"
    OS="ubuntu"
elif readfile('/etc/issue.net', 'Debian 7'):
    print "...Supported OS detected"
    OS="debian"
else:
    sys.exit("...OS is not supported")

if ARCH < 64:
    sys.exit("...Arch is not supported, Zenoss requires a 64bit OS")
if 'zenoss' in USER:
    sys.exit("...This script can not be ran by the 'zenoss' user")

# Install Package Dependencies
if 'ubuntu' in OS:
    os.system('apt-get install python-software-properties -y')
    os.system('echo | add-apt-repository ppa:webupd8team/java')
    os.system('apt-get update')
    UBUNTUPKGS
    PKGFIX
    UBUNTUPKGS
    PKGFIX
    os.system('export DEBIAN_FRONTEND=noninteractive')
    os.system('apt-get install mysql-server mysql-client mysql-common -y')
    os.system('mysql -u root -e "show databases;" > /tmp/mysqltest 2>> /tmp/mysqltest')
    if readfile('/tmp/mysqltest', 'Database'):
         MYSQLCRED="no"
         print "...MySQL connection test successful"
    else:
         
exit()
