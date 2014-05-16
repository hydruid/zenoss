#!/bin/bash
##########################################
# Version: 01a Alpha01
#  Status: Not Functional
#   Notes: Writing a backup script
##########################################

# Beginning Script Message
clear
echo && echo "Welcome to the Zenoss Backup script for Ubuntu and Debian! (http://hydruid-blog.com/?p=710)" && echo

# Script Variables
DATE=$(date +%Y%m%d_%H%M)
DBUSER="zenoss"
DBPASS="zenoss"

# Check User
if [ `whoami` != 'zenoss' ];
        then    echo "...This script should be ran by the zenoss user!" && exit 0
        else    echo "...Check User: Passed"
fi

# Zenbackup
echo "...Starting zenbackup"
zenbackup

# Directory Backup
echo "...Starting Directory Backup"
zenoss stop
tar --exclude backups --exclude perf --exclude log -czf ~/zenoss_backup_$DATE.tgz /usr/local/zenoss

# MySQL Backup
echo "...Starting MySQL Backup"
mysqldump -u$DBUSER -p$DBPASS zenoss_zep > ~/zenoss_zep_$DATE.sql
mysqldump -u$DBUSER -p$DBPASS zodb > ~/zodb_$DATE.sql
mysqldump -u$DBUSER -p$DBPASS zodb_session > ~/zodb_session_$DATE.sql

# Start Zenoss
echo "...Starting Zenoss"
zenoss start

echo && echo "The Zenoss Backup script is complete!!!" && echo
exit 0
