#!/bin/bash
#######################################################
# Version: 01a Alpha - 03                             #
#  Status: Not Functional                             #
#   Notes: Almost ready, just a few bugs to squash    #
#######################################################

# Create symbolic link
ln -s /usr/local/zenoss /opt

# Install required packages
apt-get install libssl1.0.0 libssl-dev -y
ln -s /lib/x86_64-linux-gnu/libssl.so.1.0.0 /usr/lib/libssl.so.10
ln -s /lib/x86_64-linux-gnu/libcrypto.so.1.0.0 /usr/lib/libcrypto.so.10

# Download and extract ZenUp RPM
mkdir ~zenoss/temp-zenup && cd ~zenoss/temp-zenup
wget -N http://wiki.zenoss.org/download/core/zenup/zenup-1.0.0.131-1.el6.x86_64.rpm
rpm2cpio zenup-1.0.0.131-1.el6.x86_64.rpm | cpio -i --make-directories
cp -fr ~zenoss/temp-zenup/opt/zenup /usr/local/zenoss/
chown -R zenoss:zenoss /usr/local/zenoss/zenup
ln -s /usr/local/zenoss/zenup /opt
chmod +x /usr/local/zenoss/zenup/bin/zenup

# Download Update files
wget -N http://wiki.zenoss.org/download/core/zenup/zenoss_core-4.2.4.el6-pristine.tgz -P ~zenoss/temp-zenup/
wget -N http://wiki.zenoss.org/download/core/zenup/zenoss_core-4.2.4-SP71.zup -P ~zenoss/temp-zenup/
chown -R zenoss:zenoss ~zenoss/temp-zenup
