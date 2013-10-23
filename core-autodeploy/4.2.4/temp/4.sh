#!/bin/bash

. ~zenoss/zenoss424-srpm_install/variables.sh

# Install Squeeze's version of maven and python-samba
if [ -f /etc/apt/sources.list.orig ];
then
   echo "...skipping backup of sources.list"
else
   cp /etc/apt/sources.list /etc/apt/sources.list.orig
fi
wget -N https://raw.github.com/hydruid/zenoss/master/core-autodeploy/4.2.4/misc/debian-testing-repo.list -P /root/
mv /root/debian-testing-repo.list /etc/apt/sources.list
sed -i 's:testing:squeeze:g' /etc/apt/sources.list
apt-get update
apt-get install maven python2.7-minimal python2.7 python-samba python-tdb libdcerpc0 libpython2.7 libregistry0 libsamba-policy0 python-talloc -y --force-yes

exit 0


debian-testing-repo

cp /etc/apt/sources.list /etc/apt/sources.list.orig
wget -N https://raw.github.com/hydruid/zenoss/master/core-autodeploy/4.2.4/misc/debian-testing-repo.list -P /root/
mv /root/debian-testing-repo.list /etc/apt/sources.list
apt-get update
apt-get -t testing install libc6 libc6-dev libssl-dev -y
cp /etc/apt/sources.list.orig /etc/apt/sources.list
apt-get update
apt-get -f install -y
wget -N http://ftp.us.debian.org/debian/pool/non-free/s/snmp-mibs-downloader/snmp-mibs-downloader_1.1_all.deb
dpkg -i snmp-mibs-downloader_1.1_all.deb
apt-get -f install -y
export DEBIAN_FRONTEND=noninteractive
apt-get install mysql-server mysql-client mysql-common -y
apt-get -f install -y
apt-get install libssl-dev -y
mysql-conn_test
