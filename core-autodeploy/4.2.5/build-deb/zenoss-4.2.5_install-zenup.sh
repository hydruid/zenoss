#!/bin/bash
##########################################
# Version: 01a
#  Status: Functional
#   Notes: Testing out 4.2.5
##########################################

# Installer variables
zenosshome="/home/zenoss"
downdir="/tmp"

# Create symbolic link
ln -s /usr/local/zenoss /opt

# Install required packages
apt-get install libssl1.0.0 libssl-dev -y
ln -s /lib/x86_64-linux-gnu/libssl.so.1.0.0 /usr/lib/libssl.so.10
ln -s /lib/x86_64-linux-gnu/libcrypto.so.1.0.0 /usr/lib/libcrypto.so.10

# Download and extract ZenUp RPM
mkdir $zenosshome/temp-zenup && cd $zenosshome/temp-zenup
wget -N http://wiki.zenoss.org/download/core/zenup/zenup-1.0.0.131-1.el6.x86_64.rpm
rpm2cpio zenup-1.0.0.131-1.el6.x86_64.rpm | cpio -i --make-directories
rm zenup-1.0.0.131-1.el6.x86_64.rpm
cp -fr $zenosshome/temp-zenup/opt/zenup /usr/local/zenoss/
chown -R zenoss:zenoss /usr/local/zenoss/zenup
ln -s /usr/local/zenoss/zenup /opt
chmod +x /usr/local/zenoss/zenup/bin/zenup
echo "zenoss 4.2.5-2070.el6 zenoss_core" >> /opt/zenoss/.manifest && chown -R zenoss:zenoss /opt/zenoss/.manifest
rm -fr $zenosshome/temp-zenup

echo "...Script complete"
exit 0

