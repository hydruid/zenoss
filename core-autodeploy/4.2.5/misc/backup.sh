#!/bin/bash
##########################################
# Version: 01a
#  Status: Functional
#   Notes: Writing a backup script
##########################################

# Beginning Script Message
clear
echo && echo "Welcome to the Zenoss Backup script for Ubuntu and Debian! (http://hydruid-blog.com/?p=710)" && echo

# Script Variables
export ZENHOME=/usr/local/zenoss
export PYTHONPATH=/usr/local/zenoss/lib/python
export PATH=/usr/local/zenoss/bin:$PATH
export INSTANCE_HOME=$ZENHOME
export PATH=/opt/zenup/bin:$PATH
export DEFAULT_ZEP_JVM_ARGS="-Djetty.host=localhost -server"
DATE=$(date +%Y%m%d_%H%M)
DBUSER="zenoss"
DBPASS="zenoss"
BACKUPLOC=~/zenoss-backups

# Check User
if [ `whoami` != 'zenoss' ];
        then    echo "...This script should be ran by the zenoss user!" && exit 0
        else    echo "...Check User: Passed"
fi

# Zenbackup
echo "...Starting zenbackup"
zenbackup

# Stop Zenoss
echo "...Stopping Zenoss"
zenoss stop

# Directory Backup
echo "...Starting Directory Backup"
mkdir -p $BACKUPLOC/tar
tar --exclude backups --exclude perf --exclude log -czf $BACKUPLOC/tar/zenoss_backup_$DATE.tgz /usr/local/zenoss

# MySQL Backup
echo "...Starting MySQL Backup"
mkdir -p $BACKUPLOC/sql
mysqldump -u$DBUSER -p$DBPASS zenoss_zep > $BACKUPLOC/sql/zenoss_zep_$DATE.sql
mysqldump -u$DBUSER -p$DBPASS zodb > $BACKUPLOC/sql/zodb_$DATE.sql
mysqldump -u$DBUSER -p$DBPASS zodb_session > $BACKUPLOC/sql/zodb_session_$DATE.sql

# Start Zenoss
echo "...Starting Zenoss"
zenoss start

echo && echo "The Zenoss Backup script is complete!!!" && echo
exit 0
