#!/bin/bash
##########################################
# Version: 01b
#  Status: Functional
#   Notes: Testing out 4.2.5
##########################################

read -p "Please verify that zenoss is not currently running! Press ctrl+c to cancel if needed..."

# Installer variables
ZENOSSHOME="/home/zenoss"
DOWNDIR="/tmp"
DEBVER="03c"
ZVER="425"
ZVERb="4.2.5"
ZVERc="2108"
. $ZENOSSHOME/zenoss$ZVER-srpm_install/variables.sh

# Install FPM
if [ -f /usr/local/bin/fpm ]
	then
		echo "...Skipping fpm installation"
	else
		apt-get install ruby ruby-dev -y
		gem install fpm
fi

# MySQL Dump
mysqldump -u root zenoss_zep > $ZENOSSHOME/zenoss_zep.sql
mysqldump -u root zodb > $ZENOSSHOME/zodb.sql
mysqldump -u root zodb_session > $ZENOSSHOME/zodb_session.sql

# Cleanup 
rm -fr $ZENOSSHOME/zenoss$ZVER-srpm_install/zenoss_core-$ZVERb
rm -fr $ZENOSSHOME/zenoss$ZVER-srpm_install/*.rpm
rm -fr $ZENOSSHOME/zenoss$ZVER-srpm_install/*.tar
rm -fr $ZENOSSHOME/zenoss$ZVER-srpm_install/*.spec
rm -fr $ZENOSSHOME/zenoss$ZVER-srpm_install/rrdtool-1.4.7 

# Build Deb
echo "...Building DEB"
fpm -n zenoss-core_$ZVER-$ZVERc -v $DEBVER -s dir -t deb $ZENOSSHOME /usr/local/zenoss

echo "...Script Complete, you should now have a functional DEB package!!!"
exit 0
