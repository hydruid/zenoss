#!/bin/bash
#
# Version-03
# Status: Functional but not perfect
# Notes: This script is still a work in progress, Use at your own risk!!!

sudo apt-get purge openjdk*

echo "Installing Oracle JDK "
if [ -f jdk-6u34-linux-x64.bin ];
then
        chmod u+x jdk-6u34-linux-x64.bin
else
                echo ""
                echo ""
                echo "Error:"
                echo "Oracle JDK 1.6 Update 34 not found "
                echo "Please Download jdk-6u34 from http://www.oracle.com/technetwork/java/javasebusiness/downloads/java-archive-downloads-javase6-419409.html#jdk-6u34-oth-JPR "
                echo "Save it in the same directory as install.sh"
                exit;
fi
sudo ./jdk-6u34-linux-x64.bin
sudo mkdir /usr/lib/jvm/
sudo mv jdk1.6.0_34 /usr/lib/jvm/
sudo update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk1.6.0_34/bin/javac 1
sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk1.6.0_34/bin/java 1

echo "Installing Dependencies"
sudo apt-get install rrdtool mysql-server mysql-client mysql-common libmysqlclient-dev rabbitmq-server nagios-plugins erlang subversion autoconf swig unzip g++ libssl-dev maven libmaven-compiler-plugin-java build-essential libreadline-dev libsnmp-dev zip libssl0.9.8 libxml2-dev libxslt-dev libldap2-dev libsasl2-dev snmp-mibs-downloader 

echo "Zenoss User setup"
sudo useradd -m -U -s /bin/bash zenoss
sudo mkdir /usr/local/zenoss
sudo chown -R zenoss:zenoss /usr/local/zenoss
sudo rabbitmqctl add_user zenoss zenoss
sudo rabbitmqctl add_vhost /zenoss
sudo rabbitmqctl set_permissions -p /zenoss zenoss '.*' '.*' '.*'

echo "Zenoss Installation Preparation (may take a few minutes)"
sudo svn --quiet co http://dev.zenoss.org/svn/tags/zenoss-4.2.0/inst /home/zenoss/zenoss-inst
sudo chown -R zenoss:zenoss /home/zenoss/zenoss-inst
echo "##	Ready for install!!"
echo "##	Follow the Instructions below"
echo "##"
echo "##	Modify file - sudo vi /home/zenoss/.bashrc"
echo "##    	export ZENHOME=/usr/local/zenoss"
echo "##        export PYTHONPATH=$ZENHOME/lib/python"
echo "##        export PATH=$ZENHOME/bin:$PATH"
echo "##        export INSTANCE_HOME=$ZENHOME"
echo "##	Modify file - sudo vi /etc/mysql/my.cnf"
echo "##    	max_allowed_packet=16M"
echo "##        innodb_buffer_pool_size=256M"
echo "##        innodb_additional_mem_pool_size=20M"
echo "##	Modify file - sudo vi /etc/snmp/snmp.conf"
echo "##    	#mibs :"
echo "##"
echo "##	sudo su zenoss"
echo "##	cd /home/zenoss/zenoss-inst"
echo "##	./install.sh"

echo "Zenoss Post Installation configurations"
# Nmap setuid fix
sudo chown root:zenoss /usr/local/zenoss/bin/nmap && sudo chmod u+s /usr/local/zenoss/bin/nmap
