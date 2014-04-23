#!/bin/bash
##########################################
# Version: 01a Alpha08
#  Status: Not Functional
#   Notes: Tweaking for 4.2.5
#  Zenoss: Core 4.2.5 (v2108) + ZenPacks
#      OS: Ubuntu/Debian 64-Bit
##########################################

# Beginning Script Message
clear
echo && echo "Welcome to the Zenoss 4.2.5 core-autodeploy script for Ubuntu and Debian! (http://hydruid-blog.com/?p=710)" && echo
echo "*WARNING*: THIS VERSION OF ZENOSS HAS NOT BEEN OFFICIALLY RELEASED, IT IS STILL A RC" && echo 
echo "*WARNING*: This script will update your OS and for Debian users it will install the "Testing" version of some packages."
echo "           Make sure to make a backup and/or take a snapshot!" && echo && sleep 5
echo "...Begin, we will, learn you must." && sleep 1

# Installer variables
ZENOSSHOME="/home/zenoss"
DOWNDIR="/tmp"
UPGRADE="no"
ZVER="425"
ZVERb="4.2.5"
ZVERc="2108"
DVER="03b"

# Update OS
apt-get update && apt-get dist-upgrade -y && apt-get autoremove -y

# Setup zenoss user and build environment
useradd -m -U -s /bin/bash zenoss
mkdir $ZENOSSHOME/zenoss$ZVER-srpm_install
rm -f $ZENOSSHOME/zenoss$ZVER-srpm_install/variables.sh
wget --no-check-certificate -N https://raw.github.com/hydruid/zenoss/master/core-autodeploy/$ZVERb/misc/variables.sh -P $ZENOSSHOME/zenoss$ZVER-srpm_install/
. $ZENOSSHOME/zenoss$ZVER-srpm_install/variables.sh
mkdir $ZENHOME && chown -cR zenoss:zenoss $ZENHOME

# OS compatibility tests
detect-os && detect-arch && detect-user

# Install Package Dependencies
if [ $curos = "ubuntu" ]; then
	apt-get install python-software-properties -y && sleep 1
	echo | add-apt-repository ppa:webupd8team/java && sleep 1 && apt-get update
	apt-get install rrdtool libmysqlclient-dev nagios-plugins erlang subversion autoconf swig unzip zip g++ libssl-dev maven libmaven-compiler-plugin-java build-essential libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev oracle-java7-installer python-twisted python-gnutls python-twisted-web python-samba libsnmp-base snmp-mibs-downloader bc rpm2cpio memcached libncurses5 libncurses5-dev libreadline6-dev libreadline6 librrd-dev python-setuptools python-dev erlang-nox -y
	pkg-fix
	export DEBIAN_FRONTEND=noninteractive
	apt-get install mysql-server mysql-client mysql-common -y
	mysql-conn_test
	pkg-fix
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
        pkg-fix
fi

exit 0

# Download Zenoss DEB and install it
wget -N http://master.dl.sourceforge.net/project/zenossforubuntu/zenoss-core-$ZVER-$ZVERc_$DVER_amd64.deb -P $DOWNDIR/
dpkg -i $DOWNDIR/zenoss-core-$ZVER-$ZVERc_$DVER_amd64.deb
rm -f $ZENOSSHOME/zenoss$ZVER-srpm_install/variables.sh
wget --no-check-certificate -N https://raw.github.com/hydruid/zenoss/master/core-autodeploy/$ZVERb/misc/variables.sh -P $ZENOSSHOME/zenoss$ZVER-srpm_install/
chown -R zenoss:zenoss $ZENHOME && chown -R zenoss:zenoss $ZENOSSHOME

# Import the MySQL Database and create users
if [ $UPGRADE = "no" ]; then
	if [ $mysqlcred = "yes" ]; then
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
	fi
        if [ $mysqlcred = "no" ]; then
		mysql -u$MYSQLUSER -e "create database zenoss_zep"
		mysql -u$MYSQLUSER -e "create database zodb"
		mysql -u$MYSQLUSER -e "create database zodb_session"
		echo && echo "...The 1305 MySQL import error below is safe to ignore"
		mysql -u$MYSQLUSER zenoss_zep < $ZENOSSHOME/zenoss_zep.sql
		mysql -u$MYSQLUSER zodb < $ZENOSSHOME/zodb.sql
		mysql -u$MYSQLUSER zodb_session < $ZENOSSHOME/zodb_session.sql
		mysql -u$MYSQLUSER -e "CREATE USER 'zenoss'@'localhost' IDENTIFIED BY  'zenoss';"
		mysql -u$MYSQLUSER -e "GRANT REPLICATION SLAVE ON *.* TO 'zenoss'@'localhost' IDENTIFIED BY PASSWORD '*3715D7F2B0C1D26D72357829DF94B81731174B8C';"
		mysql -u$MYSQLUSER -e "GRANT ALL PRIVILEGES ON zodb.* TO 'zenoss'@'localhost';"
		mysql -u$MYSQLUSER -e "GRANT ALL PRIVILEGES ON zenoss_zep.* TO 'zenoss'@'localhost';"
		mysql -u$MYSQLUSER -e "GRANT ALL PRIVILEGES ON zodb_session.* TO 'zenoss'@'localhost';"
		mysql -u$MYSQLUSER -e "GRANT SELECT ON mysql.proc TO 'zenoss'@'localhost';"
		mysql -u$MYSQLUSER -e "CREATE USER 'zenoss'@'%' IDENTIFIED BY  'zenoss';"
		mysql -u$MYSQLUSER -e "GRANT REPLICATION SLAVE ON *.* TO 'zenoss'@'%' IDENTIFIED BY PASSWORD '*3715D7F2B0C1D26D72357829DF94B81731174B8C';"
		mysql -u$MYSQLUSER -e "GRANT ALL PRIVILEGES ON zodb.* TO 'zenoss'@'%';"
		mysql -u$MYSQLUSER -e "GRANT ALL PRIVILEGES ON zenoss_zep.* TO 'zenoss'@'%';"
		mysql -u$MYSQLUSER -e "GRANT ALL PRIVILEGES ON zodb_session.* TO 'zenoss'@'%';"
		mysql -u$MYSQLUSER -e "GRANT SELECT ON mysql.proc TO 'zenoss'@'%';"
		rm $ZENOSSHOME/*.sql && echo
	fi
fi

# Rabbit install and config
wget -N http://www.rabbitmq.com/releases/rabbitmq-server/v3.2.3/rabbitmq-server_3.2.3-1_all.deb -P $DOWNDIR/
dpkg -i $DOWNDIR/rabbitmq-server_3.2.3-1_all.deb
chown -R zenoss:zenoss $ZENHOME && echo
rabbitmqctl add_user zenoss zenoss
rabbitmqctl add_vhost /zenoss
rabbitmqctl set_permissions -p /zenoss zenoss '.*' '.*' '.*' && echo

# Post Install Tweaks
os-fixes
echo && ln -s /usr/local/zenoss /opt
apt-get install libssl1.0.0 libssl-dev -y
ln -s /lib/x86_64-linux-gnu/libssl.so.1.0.0 /usr/lib/libssl.so.10
ln -s /lib/x86_64-linux-gnu/libcrypto.so.1.0.0 /usr/lib/libcrypto.so.10
ln -s /usr/local/zenoss/zenup /opt
chmod +x /usr/local/zenoss/zenup/bin/zenup
echo 'watchdog True' >> $ZENHOME/etc/zenwinperf.conf
touch $ZENHOME/var/Data.fs && echo
wget --no-check-certificate -N https://raw2.github.com/hydruid/zenoss/master/core-autodeploy/$ZVERb/misc/zenoss -P $DOWNDIR/
cp $DOWNDIR/zenoss /etc/init.d/zenoss
chmod 755 /etc/init.d/zenoss
update-rc.d zenoss defaults && sleep 2
echo && touch /etc/insserv/overrides/zenoss
cat > /etc/insserv/overrides/zenoss << EOL
### BEGIN INIT INFO
# Provides: zenoss-stack
# Required-Start: $local_fs $network $remote_fs
# Required-Stop: $local_fs $network $remote_fs
# Should-Start: $all
# Should-Stop: $all
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Start/stop Zenoss-stack
# Description: Start/stop Zenoss-stack
### END INIT INFO
EOL
echo && chown -c root:zenoss /usr/local/zenoss/bin/pyraw
chown -c root:zenoss /usr/local/zenoss/bin/zensocket
chown -c root:zenoss /usr/local/zenoss/bin/nmap
chmod -c 04750 /usr/local/zenoss/bin/pyraw
chmod -c 04750 /usr/local/zenoss/bin/zensocket
chmod -c 04750 /usr/local/zenoss/bin/nmap && echo
wget --no-check-certificate -N https://raw.github.com/hydruid/zenoss/master/core-autodeploy/$ZVERb/misc/secure_zenoss_ubuntu.sh -P $ZENHOME/bin
chown -c zenoss:zenoss $ZENHOME/bin/secure_zenoss_ubuntu.sh && chmod -c 0700 $ZENHOME/bin/secure_zenoss_ubuntu.sh
su -l -c "$ZENHOME/bin/secure_zenoss_ubuntu.sh" zenoss
echo '#max_allowed_packet=16M' >> /etc/mysql/my.cnf
echo 'innodb_buffer_pool_size=256M' >> /etc/mysql/my.cnf
echo 'innodb_additional_mem_pool_size=20M' >> /etc/mysql/my.cnf
sed -i 's/mibs/#mibs/g' /etc/snmp/snmp.conf

# Check log for errors
check-log

# End of Script Message
FINDIP=`ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
echo && echo "The Zenoss $ZVERb core-autodeploy script for Ubuntu is complete!!!" && echo
echo "Browse to $FINDIP:8080 to access your new Zenoss install."
echo "The default login is:"
echo "  username: admin"
echo "  password: zenoss"
