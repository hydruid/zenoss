#!/bin/bash
#######################################################
# Version: 01a Alpha - 07                             #
#  Status: Functional but not ready for production    #
#   Notes: Fixing last few bugs, before stable        #
#  Zenoss: Core 4.2.4 & ZenPacks (v1897)              #
#      OS: Debian 7 x86_64                            #
#######################################################

# Beginning Script Message
echo && echo "Welcome to the Zenoss 4.2.4 core-autodeploy script for Debian!"
echo "Blog Post: http://hydruid-blog.com/?p=343" && echo
echo "Notes: This script installs the testing version of libc6, make sure to take a snapshot or backup before installing!" && echo && sleep 5

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

# OS compatibility tests
detect-os2 && detect-arch && detect-user

# Install Package Dependencies
apt-get install python-software-properties -y && sleep 1
echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
apt-get update
apt-get install rrdtool libmysqlclient-dev nagios-plugins erlang subversion autoconf swig unzip zip g++ libssl-dev maven libmaven-compiler-plugin-java build-essential libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev oracle-java7-installer python-twisted python-gnutls python-twisted-web python-samba libsnmp-base bc rpm2cpio memcached libncurses5 libncurses5-dev libreadline6-dev libreadline6 librrd-dev python-setuptools python-dev erlang-nox smistrip -y
debian-testing-repo
wget -N http://ftp.us.debian.org/debian/pool/non-free/s/snmp-mibs-downloader/snmp-mibs-downloader_1.1_all.deb
dpkg -i snmp-mibs-downloader_1.1_all.deb
export DEBIAN_FRONTEND=noninteractive
apt-get install mysql-server mysql-client mysql-common -y
mysql-conn_test

# Download Zenoss DEB and install it
wget -N hydruid-blog.com/zenoss-core-4.2.4-1897.ubuntu.x86-64_01a_amd64.deb
dpkg -i zenoss-core-4.2.4-1897.ubuntu.x86-64_01a_amd64.deb
chown -R zenoss:zenoss $ZENHOME
give-props

# Import the MySQL Database and create users
mysql -u root -e "create database zenoss_zep"
mysql -u root -e "create database zodb"
mysql -u root -e "create database zodb_session"
mysql -u root zenoss_zep < ~zenoss/zenoss_zep.sql
mysql -u root zodb < ~zenoss/zodb.sql
mysql -u root zodb_session < ~zenoss/zodb_session.sql
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
wget -N http://www.rabbitmq.com/releases/rabbitmq-server/v3.1.5/rabbitmq-server_3.1.5-1_all.deb -P ~zenoss/zenoss424-srpm_install/
dpkg -i ~zenoss/zenoss424-srpm_install/rabbitmq-server_3.1.5-1_all.deb
chown -R zenoss:zenoss $ZENHOME
rabbitmqctl add_user zenoss zenoss
rabbitmqctl add_vhost /zenoss
rabbitmqctl set_permissions -p /zenoss zenoss '.*' '.*' '.*'

# Post Install Tweaks
echo 'watchdog True' >> $ZENHOME/etc/zenwinperf.conf
touch $ZENHOME/var/Data.fs
cp $ZENHOME/bin/zenoss /etc/init.d/zenoss
su - root -c "sed -i 's:# License.zenoss under the directory where your Zenoss product is installed.:# License.zenoss under the directory where your Zenoss product is installed.\n#\n#Custom Ubuntu Variables\nexport ZENHOME=$ZENHOME\nexport RRDCACHED=$ZENHOME/bin/rrdcached:g' /etc/init.d/zenoss"
update-rc.d zenoss defaults && sleep 2
chown -c root:zenoss /usr/local/zenoss/bin/pyraw
chown -c root:zenoss /usr/local/zenoss/bin/zensocket
chown -c root:zenoss /usr/local/zenoss/bin/nmap
chmod -c 04750 /usr/local/zenoss/bin/pyraw
chmod -c 04750 /usr/local/zenoss/bin/zensocket
chmod -c 04750 /usr/local/zenoss/bin/nmap
wget -N https://raw.github.com/hydruid/zenoss/master/core-autodeploy/4.2.4/misc/secure_zenoss_ubuntu.sh -P $ZENHOME/bin
chown -c zenoss:zenoss $ZENHOME/bin/secure_zenoss_ubuntu.sh && chmod -c 0700 $ZENHOME/bin/secure_zenoss_ubuntu.sh
su -l -c "$ZENHOME/bin/secure_zenoss_ubuntu.sh" zenoss
echo '#max_allowed_packet=16M' >> /etc/mysql/my.cnf
echo 'innodb_buffer_pool_size=256M' >> /etc/mysql/my.cnf
echo 'innodb_additional_mem_pool_size=20M' >> /etc/mysql/my.cnf
sed -i 's/mibs/#mibs/g' /etc/snmp/snmp.conf
ln -s /usr/local/zenoss /opt/

# End of Script Message
FINDIP=`ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'
echo && echo "The Zenoss 4.2.4 core-autodeploy script for Ubuntu is complete!!!" && echo
echo "Browse to $FINDIP:8080 to access your new Zenoss install."
echo "The default login is:"
echo "  username: admin"
echo "  password: zenoss"
