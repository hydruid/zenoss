#!/bin/bash
#######################################################
# Version: 01a                                        #
#  Status: Functional                                 #
#######################################################

# Installer variables
## Home path for the zenoss user
zenosshome="/home/zenoss"
## Download Directory
downdir="/tmp"
. $zenosshome/zenoss424-srpm_install/variables.sh

# Install FPM
if [ -f /usr/local/bin/fpm ]
	then
		echo "...Skipping fpm installation"
	else
		apt-get install rubygems -y
		gem install fpm
fi

# MySQL Dump
mysqldump -u root zenoss_zep > $zenosshome/zenoss_zep.sql
mysqldump -u root zodb > $zenosshome/zodb.sql
mysqldump -u root zodb_session > $zenosshome/zodb_session.sql

# Cleanup 
rm -fr $zenosshome/zenoss424-srpm_install/zenoss_core-4.2.4
rm -fr $zenosshome/zenoss424-srpm_install/*.rpm
rm -fr $zenosshome/zenoss424-srpm_install/*.tar
rm -fr $zenosshome/zenoss424-srpm_install/*.spec

# Build Deb
echo "...Building DEB"
fpm -n zenoss-core_424-1897 -v 02a -s dir -t deb $zenosshome /usr/local/zenoss

echo "...Script Complete"
exit 0
