#!/bin/bash
#######################################################
# Version: 01a Alpha - 03                             #
#  Status: Not Functional                             #
#   Notes: Various daemons are broken                 #
#  Zenoss: Core 4.2.4 & ZenPacks (v1897)              #
#      OS: Debian 7 x86_64                            #
#######################################################

# Beginning Script Message
echo && echo "Welcome to the Zenoss 4.2.4 core-autodeploy script for Debian!"
echo "Blog Post: http://hydruid-blog.com/?p=343" && echo && sleep 5

# Update Debian
apt-get update && apt-get dist-upgrade -y && apt-get autoremove -y

# Setup zenoss user and build environment
useradd -m -U -s /bin/bash zenoss
chmod 777 /home/zenoss/.bashrc
echo 'export ZENHOME=/usr/local/zenoss' >> /home/zenoss/.bashrc
echo 'export PYTHONPATH=/usr/local/zenoss/lib/python' >> /home/zenoss/.bashrc
echo 'export PATH=/usr/local/zenoss/bin:$PATH' >> /home/zenoss/.bashrc
echo 'export INSTANCE_HOME=$ZENHOME' >> /home/zenoss/.bashrc
chmod 644 /home/zenoss/.bashrc
mkdir /home/zenoss/zenoss424-srpm_install
wget -N https://raw.github.com/hydruid/zenoss/master/core-autodeploy/4.2.4/misc/variables.sh -P /home/zenoss/zenoss424-srpm_install/
. /home/zenoss/zenoss424-srpm_install/variables.sh
mkdir $ZENHOME && chown -cR zenoss:zenoss $ZENHOME

# OS compatibility tests
if grep -Fxq "testing" /etc/apt/sources.list
        then echo "...Detected testing repo."
        else echo "...Did not detect testing repo, see https://wiki.debian.org/DebianTesting" && exit 0
fi
detect-os2 && detect-arch && detect-user

# Install Package Dependencies
apt-get install python-software-properties -y && sleep 1
echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
apt-get update
apt-get install rrdtool libmysqlclient-dev nagios-plugins erlang subversion autoconf swig unzip zip g++ libssl-dev maven libmaven-compiler-plugin-java build-essential libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev oracle-java7-installer python-twisted python-gnutls python-twisted-web python-samba libsnmp-base bc rpm2cpio memcached libncurses5 libncurses5-dev libreadline6-dev libreadline6 librrd-dev python-setuptools python-dev erlang-nox smistrip -y
apt-get -t testing install libc6
wget -N http://ftp.us.debian.org/debian/pool/non-free/s/snmp-mibs-downloader/snmp-mibs-downloader_1.1_all.deb
dpkg -i snmp-mibs-downloader_1.1_all.deb
export DEBIAN_FRONTEND=noninteractive
apt-get install mysql-server mysql-client mysql-common -y
mysql-conn_test

# Download Zenoss DEB and install it
wget -N hydruid-blog.com/zenoss-core-4.2.4-1897.ubuntu.x86-64_01a_amd64.deb
dpkg -i zenoss-core-4.2.4-1897.ubuntu.x86-64_01a_amd64.deb
chown -R zenoss:zenoss $ZENHOME

# Import the MySQL Database and create users
mysql -u root -e "create database zenoss_zep"
mysql -u root -e "create database zodb"
mysql -u root -e "create database zodb_session"
mysql -u root zenoss_zep < /home/zenoss/zenoss_zep.sql
mysql -u root zodb < /home/zenoss/zodb.sql
mysql -u root zodb_session < /home/zenoss/zodb_session.sql
mysql -u root -e "CREATE USER 'zenoss'@'localhost' IDENTIFIED BY  'zenoss';"
mysql -u root -e "GRANT REPLICATION SLAVE ON *.* TO 'zenoss'@'localhost' IDENTIFIED BY PASSWORD '*3715D7F2B0C1D26D72357829DF94B81731174B8C';"
mysql -u root -e "GRANT ALL PRIVILEGES ON zodb.* TO 'zenoss'@'localhost';"
mysql -u root -e "GRANT ALL PRIVILEGES ON zenoss_zep.* TO 'zenoss'@'localhost';"
mysql -u root -e "GRANT ALL PRIVILEGES ON zodb_session.* TO 'zenoss'@'localhost';"
mysql -u root -e "GRANT SELECT ON mysql.proc TO 'zenoss'@'localhost';"
mysql -u root -e "CREATE USER 'zenoss'@'%' IDENTIFIED BY  'zenoss';"
mysql -u root -e "GRANT REPLICATION SLAVE ON *.* TO 'zenoss'@'%' IDENTIFIED BY PASSWORD '*3715D7F2B0C1D26D72357829DF94B81731174B8C';"
mysql -u root -e "GRANT ALL PRIVILEGES ON zodb.* TO 'zenoss'@'%';"
mysql -u root -e "GRANT ALL PRIVILEGES ON zenoss_zep.* TO 'zenoss'@'%';"
mysql -u root -e "GRANT ALL PRIVILEGES ON zodb_session.* TO 'zenoss'@'%';"
mysql -u root -e "GRANT SELECT ON mysql.proc TO 'zenoss'@'%';"

# Rabbit install and config
wget -N http://www.rabbitmq.com/releases/rabbitmq-server/v3.1.5/rabbitmq-server_3.1.5-1_all.deb -P /home/zenoss/zenoss424-srpm_install/
dpkg -i /home/zenoss/zenoss424-srpm_install/rabbitmq-server_3.1.5-1_all.deb
chown -R zenoss:zenoss $ZENHOME
rabbitmqctl add_user zenoss zenoss
rabbitmqctl add_vhost /zenoss
rabbitmqctl set_permissions -p /zenoss zenoss '.*' '.*' '.*'

echo "...stopping here"
echo "...this section still under development"
echo "...su to the zenoss user and issue, zenoss start"
exit 0
