#!/bin/bash
#######################################################
# Version: 03a Alpha - 05                             #
#  Status: Functional                                 #
#   Notes: Includes updated DEB with ZenUP            #
#  Zenoss: Core 4.2.4 & ZenPacks (v1897)              #
#      OS: Ubuntu 12/13 x86_64                        #
#######################################################

# Beginning Script Message
echo && echo "Welcome to the Zenoss 4.2.4 core-autodeploy script for Ubuntu!"
echo "Blog Post: http://hydruid-blog.com/?p=343" && echo 
echo "Notes: All feedback and suggestions are appreciated." && echo && sleep 5

# Installer variables
## Home path for the zenoss user
zenosshome="/home/zenoss"
## Download Directory
downdir="/tmp"

# Update Ubuntu
apt-get update && apt-get dist-upgrade -y && apt-get autoremove -y

# Setup zenoss user and build environment
useradd -m -U -s /bin/bash zenoss
chmod 777 $zenosshome/.bashrc
echo 'export ZENHOME=/usr/local/zenoss' >> $zenosshome/.bashrc
echo 'export PYTHONPATH=/usr/local/zenoss/lib/python' >> $zenosshome/.bashrc
echo 'export PATH=/usr/local/zenoss/bin:$PATH' >> $zenosshome/.bashrc
echo 'export INSTANCE_HOME=$ZENHOME' >> $zenosshome/.bashrc
echo 'export PATH=/opt/zenup/bin:$PATH' >> $zenosshome/.bashrc
chmod 644 $zenosshome/.bashrc
mkdir $zenosshome/zenoss424-srpm_install
wget --no-check-certificate -N https://raw.github.com/hydruid/zenoss/master/core-autodeploy/4.2.4/misc/variables.sh -P $zenosshome/zenoss424-srpm_install/
. $zenosshome/zenoss424-srpm_install/variables.sh
mkdir $ZENHOME && chown -cR zenoss:zenoss $ZENHOME

# OS compatibility tests
detect-os2 && detect-arch && detect-user

# Install Package Dependencies
## Java PPA
apt-get install python-software-properties -y && sleep 1
echo | add-apt-repository ppa:webupd8team/java && sleep 1 && apt-get update
## Install Packages
apt-get install rrdtool libmysqlclient-dev nagios-plugins erlang subversion autoconf swig unzip zip g++ libssl-dev maven libmaven-compiler-plugin-java build-essential libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev oracle-java7-installer python-twisted python-gnutls python-twisted-web python-samba libsnmp-base snmp-mibs-downloader bc rpm2cpio memcached libncurses5 libncurses5-dev libreadline6-dev libreadline6 librrd-dev python-setuptools python-dev erlang-nox -y
pkg-fix
## MySQL Packages
export DEBIAN_FRONTEND=noninteractive
apt-get install mysql-server mysql-client mysql-common -y
mysql-conn_test
pkg-fix

# Download Zenoss DEB and install it
wget -N hydruid-blog.com/zenoss-core-424-1897_02a_amd64.deb -P $downdir/
dpkg -i $downdir/zenoss-core-424-1897_02a_amd64.deb
chown -R zenoss:zenoss $ZENHOME
give-props

# Import the MySQL Database and create users
mysql -u root -e "create database zenoss_zep"
mysql -u root -e "create database zodb"
mysql -u root -e "create database zodb_session"
echo "...The 1305 MySQL import error below is save to ignore"
mysql -u root zenoss_zep < $zenosshome/zenoss_zep.sql
mysql -u root zodb < $zenosshome/zodb.sql
mysql -u root zodb_session < $zenosshome/zodb_session.sql
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
wget -N http://www.rabbitmq.com/releases/rabbitmq-server/v3.2.1/rabbitmq-server_3.2.1-1_all.deb -P $downdir/
dpkg -i $downdir/rabbitmq-server_3.2.1-1_all.deb
chown -R zenoss:zenoss $ZENHOME
rabbitmqctl add_user zenoss zenoss
rabbitmqctl add_vhost /zenoss
rabbitmqctl set_permissions -p /zenoss zenoss '.*' '.*' '.*'

# Post Install Tweaks
## ZenUp
ln -s /usr/local/zenoss /opt
apt-get install libssl1.0.0 libssl-dev -y
ln -s /lib/x86_64-linux-gnu/libssl.so.1.0.0 /usr/lib/libssl.so.10
ln -s /lib/x86_64-linux-gnu/libcrypto.so.1.0.0 /usr/lib/libcrypto.so.10
ln -s /usr/local/zenoss/zenup /opt
chmod +x /usr/local/zenoss/zenup/bin/zenup
## Misc.
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
wget --no-check-certificate -N https://raw.github.com/hydruid/zenoss/master/core-autodeploy/4.2.4/misc/secure_zenoss_ubuntu.sh -P $ZENHOME/bin
chown -c zenoss:zenoss $ZENHOME/bin/secure_zenoss_ubuntu.sh && chmod -c 0700 $ZENHOME/bin/secure_zenoss_ubuntu.sh
su -l -c "$ZENHOME/bin/secure_zenoss_ubuntu.sh" zenoss
echo '#max_allowed_packet=16M' >> /etc/mysql/my.cnf
echo 'innodb_buffer_pool_size=256M' >> /etc/mysql/my.cnf
echo 'innodb_additional_mem_pool_size=20M' >> /etc/mysql/my.cnf
sed -i 's/mibs/#mibs/g' /etc/snmp/snmp.conf

# End of Script Message
FINDIP=`ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
echo && echo "The Zenoss 4.2.4 core-autodeploy script for Ubuntu is complete!!!" && echo
echo "Browse to $FINDIP:8080 to access your new Zenoss install."
echo "The default login is:"
echo "  username: admin"
echo "  password: zenoss"
