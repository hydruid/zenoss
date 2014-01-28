#!/bin/bash
##########################################
# Version: 04d Alpha04
#  Status: Not Functional
#   Notes: Upddating MySQL Section
#  Zenoss: Core 4.2.4 (v1897) + ZenPacks
#      OS: Ubuntu/Debian 64-Bit
##########################################

# Beginning Script Message
clear
echo && echo "Welcome to the Zenoss 4.2.4 core-autodeploy script for Ubuntu and Debian! (http://hydruid-blog.com/?p=241)" && echo
echo "*WARNING*: This script will update your OS and for Debian users it will install the "Testing" version of some packages."
echo "           Make sure to make a backup and/or take a snapshot!" && echo && sleep 5
echo "...Begin, we will, learn you must." && sleep 1

# Installer variables
ZENOSSHOME="/home/zenoss"
DOWNDIR="/tmp"
UPGRADE="NO"

# Update OS
apt-get update && apt-get dist-upgrade -y && apt-get autoremove -y && echo

# Setup zenoss user and build environment
echo && useradd -m -U -s /bin/bash zenoss && echo
mkdir $ZENOSSHOME/zenoss424-srpm_install
rm -f $ZENOSSHOME/zenoss424-srpm_install/variables.sh
wget --no-check-certificate -N https://raw.github.com/hydruid/zenoss/master/core-autodeploy/4.2.4/misc/variables.sh -P $ZENOSSHOME/zenoss424-srpm_install/
. $ZENOSSHOME/zenoss424-srpm_install/variables.sh
mkdir $ZENHOME && chown -cR zenoss:zenoss $ZENHOME

# OS compatibility tests
detect-os && detect-arch && detect-user && echo

# Install Package Dependencies
if [ $curos = "ubuntu" ]; then
	apt-get install python-software-properties -y && sleep 1
	echo | add-apt-repository ppa:webupd8team/java && sleep 1 && apt-get update
	apt-get install rrdtool libmysqlclient-dev nagios-plugins erlang subversion autoconf swig unzip zip g++ libssl-dev maven libmaven-compiler-plugin-java build-essential libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev oracle-java7-installer python-twisted python-gnutls python-twisted-web python-samba libsnmp-base snmp-mibs-downloader bc rpm2cpio memcached libncurses5 libncurses5-dev libreadline6-dev libreadline6 librrd-dev python-setuptools python-dev erlang-nox -y
	pkg-fix
	export DEBIAN_FRONTEND=noninteractive
	apt-get install mysql-server mysql-client mysql-common -y
	mysql-conn_test
	echo && pkg-fix
fi
if [ $curos = "debian" ]; then
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
        echo && pkg-fix
fi

# Download Zenoss DEB and install it
wget -N http://master.dl.sourceforge.net/project/zenossforubuntu/zenoss-core-424-1897_02a_amd64.deb -P $DOWNDIR/
dpkg -i $DOWNDIR/zenoss-core-424-1897_02a_amd64.deb
rm -f $ZENOSSHOME/zenoss424-srpm_install/variables.sh
wget --no-check-certificate -N https://raw.github.com/hydruid/zenoss/master/core-autodeploy/4.2.4/misc/variables.sh -P $ZENOSSHOME/zenoss424-srpm_install/
chown -R zenoss:zenoss $ZENHOME

# Import the MySQL Database and create users
mysql -u$MYSQLUSER -p$MYSQLPASS -e "create database zenoss_zep"
mysql -u$MYSQLUSER -p$MYSQLPASS -e "create database zodb"
mysql -u$MYSQLUSER -p$MYSQLPASS -e "create database zodb_session"
echo && echo "...The 1305 MySQL import error below is safe to ignore"
mysql -u$MYSQLUSER -p$MYSQLPASS zenoss_zep < $ZENOSSHOME/zenoss_zep.sql
mysql -u$MYSQLUSER -p$MYSQLPASS zodb < $ZENOSSHOME/zodb.sql
mysql -u$MYSQLUSER -p$MYSQLPASS zodb_session < $ZENOSSHOME/zodb_session.sql
mysql -u$MYSQLUSER -p$MYSQLPASS -e "CREATE USER 'zenoss'@'localhost' IDENTIFIED BY  'zenoss';"
mysql -u$MYSQLUSER -p$MYSQLPASS -e "GRANT REPLICATION SLAVE ON *.* TO 'zenoss'@'localhost' IDENTIFIED BY PASSWORD '*3715D7F2B0C1D26D72357829DF94B81731174B8C';"
mysql -u$MYSQLUSER -p$MYSQLPASS -e "GRANT ALL PRIVILEGES ON zodb.* TO 'zenoss'@'localhost';"
mysql -u$MYSQLUSER -p$MYSQLPASS -e "GRANT ALL PRIVILEGES ON zenoss_zep.* TO 'zenoss'@'localhost';"
mysql -u$MYSQLUSER -p$MYSQLPASS -e "GRANT ALL PRIVILEGES ON zodb_session.* TO 'zenoss'@'localhost';"
mysql -u$MYSQLUSER -p$MYSQLPASS -e "GRANT SELECT ON mysql.proc TO 'zenoss'@'localhost';"
mysql -u$MYSQLUSER -p$MYSQLPASS -e "CREATE USER 'zenoss'@'%' IDENTIFIED BY  'zenoss';"
mysql -u$MYSQLUSER -p$MYSQLPASS -e "GRANT REPLICATION SLAVE ON *.* TO 'zenoss'@'%' IDENTIFIED BY PASSWORD '*3715D7F2B0C1D26D72357829DF94B81731174B8C';"
mysql -u$MYSQLUSER -p$MYSQLPASS -e "GRANT ALL PRIVILEGES ON zodb.* TO 'zenoss'@'%';"
mysql -u$MYSQLUSER -p$MYSQLPASS -e "GRANT ALL PRIVILEGES ON zenoss_zep.* TO 'zenoss'@'%';"
mysql -u$MYSQLUSER -p$MYSQLPASS -e "GRANT ALL PRIVILEGES ON zodb_session.* TO 'zenoss'@'%';"
mysql -u$MYSQLUSER -p$MYSQLPASS -e "GRANT SELECT ON mysql.proc TO 'zenoss'@'%';"
rm $ZENOSSHOME/*.sql && echo 

# Rabbit install and config
wget -N http://www.rabbitmq.com/releases/rabbitmq-server/v3.2.3/rabbitmq-server_3.2.3-1_all.deb -P $DOWNDIR/
dpkg -i $DOWNDIR/rabbitmq-server_3.2.3-1_all.deb
chown -R zenoss:zenoss $ZENHOME
rabbitmqctl add_user zenoss zenoss
rabbitmqctl add_vhost /zenoss
rabbitmqctl set_permissions -p /zenoss zenoss '.*' '.*' '.*'

# Post Install Tweaks
os-fixes
ln -s /usr/local/zenoss /opt
apt-get install libssl1.0.0 libssl-dev -y
ln -s /lib/x86_64-linux-gnu/libssl.so.1.0.0 /usr/lib/libssl.so.10
ln -s /lib/x86_64-linux-gnu/libcrypto.so.1.0.0 /usr/lib/libcrypto.so.10
ln -s /usr/local/zenoss/zenup /opt
chmod +x /usr/local/zenoss/zenup/bin/zenup
echo 'watchdog True' >> $ZENHOME/etc/zenwinperf.conf
touch $ZENHOME/var/Data.fs
wget --no-check-certificate -N https://raw2.github.com/hydruid/zenoss/master/core-autodeploy/4.2.4/misc/zenoss -P $DOWNDIR/
cp $DOWNDIR/zenoss /etc/init.d/zenoss
chmod 755 /etc/init.d/zenoss
update-rc.d zenoss defaults && sleep 2
touch /etc/insserv/overrides/zenoss
cat > /etc/insserv/overrides/zenoss << EOL
### BEGIN INIT INFO
# Provides: zenoss-stack
# Required-Start: $local_fs $remote_fs
# Required-Stop: $local_fs $remote_fs
# Should-Start: $all
# Should-Stop: $all
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Start/stop Zenoss-stack
# Description: Start/stop Zenoss-stack
### END INIT INFO
EOL
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
