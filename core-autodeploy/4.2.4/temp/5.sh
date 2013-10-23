#!/bin/bash

. ~zenoss/zenoss424-srpm_install/variables.sh

# Download Zenoss DEB and install it
wget -N hydruid-blog.com/zenoss-core-4.2.4-1897.ubuntu.x86-64_01a_amd64.deb
dpkg -i zenoss-core-4.2.4-1897.ubuntu.x86-64_01a_amd64.deb
chown -R zenoss:zenoss $ZENHOME
#give-props

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
rm ~zenoss/*.sql

# Rabbit install and config
wget -N http://www.rabbitmq.com/releases/rabbitmq-server/v3.1.5/rabbitmq-server_3.1.5-1_all.deb -P ~zenoss/zenoss424-srpm_install/
dpkg -i ~zenoss/zenoss424-srpm_install/rabbitmq-server_3.1.5-1_all.deb
chown -R zenoss:zenoss $ZENHOME
rabbitmqctl add_user zenoss zenoss
rabbitmqctl add_vhost /zenoss
rabbitmqctl set_permissions -p /zenoss zenoss '.*' '.*' '.*'
