#!/bin/bash
#######################################################
# Version: 01a Alpha - 04                             #
#  Status: Functional...Not ready for production      #
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
echo "zenoss 4.2.4-1897.el6 zenoss_core" >> /opt/zenoss/.manifest && chown -R zenoss:zenoss /opt/zenoss/.manifest
wget -N https://raw.github.com/hydruid/zenoss/master/core-autodeploy/4.2.4/misc/zenup-helper.sh -P ~zenoss/temp-zenup/ && chmod +x zenup-helper.sh
su - zenoss -c '/bin/sh ~zenoss/temp-zenup/zenup-helper.sh'
