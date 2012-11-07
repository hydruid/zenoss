# Version-01
# Status: Very experimental
# Notes: This script is still a work in progress, Use at your own risk!!!

# 1. Oracle Java 1.6 Update 31 or later (1.7 is not supported)
# Download jdk-6u34 from http://www.oracle.com/technetwork/java/javasebusiness/downloads/java-archive-downloads-javase6-419409.html#jdk-6u34-oth-JPR
chmod u+x jdk-6u34-linux-x64.bin
sudo ./jdk-6u34-linux-x64.bin
sudo mkdir /usr/lib/jvm/
sudo mv jdk1.6.0_34 /usr/lib/jvm/ 	
sudo update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk1.6.0_34/bin/javac 1
sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk1.6.0_34/bin/java 1

# 2. RRDtool 1.4.7 or later
sudo apt-get install rrdtool
dpkg -s rrdtool

# 3. MySQL Community Server 5.5.25 or later
sudo apt-get install mysql-server mysql-client mysql-common libmysqlclient-dev
# specify mysql root password (do not leave blank)
dpkg -s mysql-server
sudo vi /etc/mysql/my.cnf
	Add/Update the following lines
		[mysqld]
		max_allowed_packet=16M
		innodb_buffer_pool_size=256M
		innodb_additional_mem_pool_size=20M
sudo mysqladmin -u root -p password ''
sudo mysqladmin -u root -h localhost password ''

# 4. RabbitMQ 2.8.4 or later
sudo apt-get install rabbitmq-server
dpkg -s rabbitmq-server

# 5. Nagios Plugins 1.4.15 or later
sudo apt-get install nagios-plugins
dpkg -s nagios-plugins

# 6. Erlang R12B
sudo apt-get install erlang
dpkg -s erlang

# 7. Zenoss User setup
sudo useradd -m -U -s /bin/bash zenoss
sudo mkdir /usr/local/zenoss
sudo chown -R zenoss:zenoss /usr/local/zenoss
# sudo vi /home/zenoss/.bashrc
#	Add/Update the following lines
#		export ZENHOME=/usr/local/zenoss
#		export PYTHONPATH=$ZENHOME/lib/python
#		export PATH=$ZENHOME/bin:$PATH
#		export INSTANCE_HOME=$ZENHOME
sudo rabbitmqctl add_user zenoss zenoss
sudo rabbitmqctl add_vhost /zenoss
sudo rabbitmqctl set_permissions -p /zenoss zenoss '.*' '.*' '.*'

# 8. Zenoss Install
sudo apt-get install subversion autoconf swig unzip g++ libssl-dev maven libmaven-compiler-plugin-java build-essential libreadline-dev libsnmp-dev zip libssl0.9.8 libxml2-dev libxslt-dev libldap2-dev libsasl2-dev
sudo svn --quiet co http://dev.zenoss.org/svn/tags/zenoss-4.2.0/inst /home/zenoss/zenoss-inst
sudo chown -R zenoss:zenoss /home/zenoss/zenoss-inst
sudo su zenoss
cd /home/zenoss/zenoss-inst
./install.sh
