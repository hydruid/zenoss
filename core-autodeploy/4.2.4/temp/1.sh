#!/bin/bash


# Update Debian
apt-get update && apt-get dist-upgrade -y && apt-get autoremove -y

# Setup zenoss user and build environment
useradd -m -U -s /bin/bash zenoss
chmod 777 ~zenoss/.bashrc
echo 'export ZENHOME=/usr/local/zenoss' >> ~zenoss/.bashrc
echo 'export PYTHONPATH=/usr/local/zenoss/lib/python' >> ~zenoss/.bashrc
echo 'export PATH=/usr/local/zenoss/bin:$PATH' >> ~zenoss/.bashrc
echo 'export INSTANCE_HOME=$ZENHOME' >> ~zenoss/.bashrc
chmod 644 ~zenoss/.bashrc
mkdir ~zenoss/zenoss424-srpm_install
wget -N https://raw.github.com/hydruid/zenoss/master/core-autodeploy/4.2.4/misc/variables.sh -P ~zenoss/zenoss424-srpm_install/
. ~zenoss/zenoss424-srpm_install/variables.sh
mkdir $ZENHOME && chown -cR zenoss:zenoss $ZENHOME
