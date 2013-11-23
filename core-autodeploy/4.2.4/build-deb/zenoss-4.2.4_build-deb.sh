#!/bin/bash
#######################################################
# Version: 01a Alpha - 01                             #
#  Status: Not Functional                             #
#######################################################

# Installer variables
## Home path for the zenoss user
zenosshome="/home/zenoss"
## Download Directory
downdir="/tmp"
. $zenosshome/zenoss424-srpm_install/variables.sh

# Install FPM
apt-get install rubygems -y
gem install fpm

# Build Deb
fpm -n zenoss-core_424-1897 -v 1.0 -s dir -t deb /home/zenoss/ /usr/local/zenoss

echo "...Script Complete, Congratulations on creating a Zenoss Deb!!!!"
exit 0
