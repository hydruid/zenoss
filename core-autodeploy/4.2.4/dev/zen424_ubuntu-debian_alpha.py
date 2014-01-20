#!/usr/bin/env python
#######################################################
# Version: 01a Alpha07
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
import MySQLdb

# Script variables
ZENOSSHOME="/home/zenoss"
DOWNDIR="/tmp"
VARURL="https://raw.github.com/hydruid/zenoss/master/core-autodeploy/4.2.4/dev/variables.py"
DEBURL="http://master.dl.sourceforge.net/project/zenossforubuntu/zenoss-core-424-1897_02a_amd64.deb"
ZENUID=pwd.getpwnam("zenoss").pw_uid
ZENGID=grp.getgrnam("zenoss").gr_gid
MYSQLUSER="root"
MYSQLPASS=""

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
with open(os.path.join(ZENOSSHOME, '.bashrc'), "a") as f:
    f.write("export ZENHOME=/usr/local/zenoss\nexport PYTHONPATH=/usr/local/zenoss/lib/python\nexport PATH=/usr/local/zenoss/bin:$PATH\nexport INSTANCE_HOME=$ZENHOME\nexport PATH=/opt/zenup/bin:$PATH")
if not os.path.exists(os.path.join(ZENOSSHOME, 'zenoss424-srpm_install')):
    os.makedirs(os.path.join(ZENOSSHOME, 'zenoss424-srpm_install'))
urllib.urlretrieve(VARURL, os.path.join(ZENOSSHOME, "zenoss424-srpm_install/variables.py"))
execfile("/home/zenoss/zenoss424-srpm_install/variables.py")
if not os.path.exists(ZENHOME):
    os.makedirs(ZENHOME)
os.chown(ZENHOME, ZENUID, ZENGID)

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
    db = MySQLdb.connect("localhost",MYSQLUSER,MYSQLPASS,"test" )
    cursor = db.cursor()
    cursor.execute("SELECT VERSION()")
    data = cursor.fetchone()
    print "...Testing MySQL Database\n......Database version : %s " % data
    db.close()
if 'debian' in OS:
    os.system('apt-get install python-software-properties -y')
    os.system('echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list')
    os.system('echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.lis')
    os.system('apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886')
    os.system('apt-get update')
    DEBIANPKGS
    PKGFIX
    DEBIANPKGS
    PKGFIX
    print "...THIS SECTION NOT COMPLETE"

# Download Zenoss DEB and install it
print "...Downloading Zenoss DEB"
urllib.urlretrieve(DEBURL, os.path.join(DOWNDIR, 'zenoss-core-424-1897_02a_amd64.deb'))
DEBINSTALL=os.path.join('dpkg -i ', DOWNDIR.strip("/"), 'zenoss-core-424-1897_02a_amd64.deb')
os.system(DEBINSTALL)
os.chown(ZENHOME, ZENUID, ZENGID)

# Import the MySQL Database and create users
db = MySQLdb.connect("localhost",MYSQLUSER,MYSQLPASS,"test" )
cursor = db.cursor()
COMMANDS = ('CREATE DATABASE zenoss_zep','CREATE DATABASE zodb','CREATE DATBASE zodb_session','zenoss_zep < $zenosshome/zenoss_zep.sql','zodb < $zenosshome/zodb.sql','zodb_session < $zenosshome/zodb_session.sql','CREATE USER zenoss@localhost IDENTIFIED BY zenoss','GRANT REPLICATION SLAVE ON *.* TO zenoss@localhost IDENTIFIED BY PASSWORD *3715D7F2B0C1D26D72357829DF94B81731174B8C','GRANT ALL PRIVILEGES ON zodb.* TO zenoss@localhost','GRANT ALL PRIVILEGES ON zodb.* TO zenoss@localhost','GRANT ALL PRIVILEGES ON zenoss_zep.* TO zenoss@localhost','GRANT ALL PRIVILEGES ON zodb_session.* TO zenoss@localhost','GRANT SELECT ON mysql.proc TO zenoss@localhost','CREATE USER zenoss@% IDENTIFIED BY zenoss','GRANT REPLICATION SLAVE ON *.* TO zenoss@% IDENTIFIED BY PASSWORD *3715D7F2B0C1D26D72357829DF94B81731174B8C','GRANT ALL PRIVILEGES ON zodb.* TO zenoss@%','GRANT ALL PRIVILEGES ON zenoss_zep.* TO zenoss@%','GRANT ALL PRIVILEGES ON zodb_session.* TO zenoss@%','GRANT SELECT ON mysql.proc TO zenoss@%')
for COMMAND in COMMANDS:
    cursor.execute(COMMAND)
db.close()

exit()
