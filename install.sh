#!/bin/bash
###########################################################
#
# A simple script to auto-install Zenoss Core 4.2
#
# This script should be run on a base install of
# Ubuntu 12.04 x64
#
# Status: Broken....seems after updates missing dependencies
# Version: 04-Beta06
#
###########################################################


#Preinstall Checks
checkenable='no'
if [ $checkenable = "no" ];
        then
		echo "Preinstall checks disabled......"
        else
		echo "Preinstall checks enabled......"
		search=$(dpkg --list | egrep -i "mysql-")
		if [ "" == "$search" ];
		        then
               			echo "MySQL Preinstall Check: Pass"
        		else
                		echo "It appears that the distro-supplied version of MySQL is at least partially installed."
               			echo "Please remove these packages, as well as their dependencies, and then retry this script:"
		                echo "$ sudo dpkg --list | grep mysql"
		                echo ""
		                echo "Example command to remove mysql-* packages"
		                echo "$ sudo apt-get remove mysql-client"
		                echo "$ sudo apt-get --purge remove libdbd-mysql-perl libmysqlclient18 mysql-client-5.5 mysql-client-core-5.5 mysql-common"
		                exit
		fi
		search=$(dpkg --list | egrep -i "openjdk")
		if [ "" == "$search" ];
		        then
		                echo "Openjdk Preinstall Check: Pass"
			else
		                echo "It appears that the distro-supplied version of OpenJDK is at least partially installed."
		                echo "Please remove these packages, as well as their dependencies, and then retry this script:"
		                echo "$ sudo dpkg --list | grep openjdk"
		                echo ""
		                echo "Example command to remove openjdk-* packages"
		                echo "$ sudo apt-get purge openjdk*"
		                exit
		fi
fi

echo "Installing Oracle JDK1.6_34u...."
if [ -f /usr/lib/jvm/jdk1.6.0_34/COPYRIGHT ];
	then
		echo "Oracle JDK1.6_34u Already Installed.....Skipping" 
	else
	if [ -f jdk-6u34-linux-x64.bin ];
		then
			echo "Oracle JDK1.6_u34 .bin found"
			chmod u+x jdk-6u34-linux-x64.bin
			sudo ./jdk-6u34-linux-x64.bin
			sudo mkdir /usr/lib/jvm/
			sudo mv jdk1.6.0_34 /usr/lib/jvm/
		else
			echo ""
			echo ""
			echo "#######Error:#######"
			echo "Oracle JDK1.6_u34 .bin not found "
			echo "Please Download jdk-6u34-linux-x64.bin from the below link"
			echo "http://www.oracle.com/technetwork/java/javasebusiness/downloads/java-archive-downloads-javase6-419409.html#jdk-6u34-oth-JPR "
			echo "Save it in the same directory as install.sh"
			exit
	fi
fi

echo "Installing Dependencies"
sudo apt-get install rrdtool mysql-server mysql-client mysql-common libmysqlclient-dev rabbitmq-server nagios-plugins erlang subversion autoconf swig unzip g++ libssl-dev maven libmaven-compiler-plugin-java build-essential libreadline-dev libsnmp-dev zip libssl0.9.8 libxml2-dev libxslt-dev libldap2-dev libsasl2-dev snmp-mibs-downloader python-qt4reactor python-twisted python-gnutls python-twisted-web ia32-libs

#echo "Zenoss User setup"
sudo useradd -m -U -s /bin/bash zenoss
sudo mkdir /usr/local/zenoss
sudo chown -R zenoss:zenoss /usr/local/zenoss
sudo rabbitmqctl add_user zenoss zenoss
sudo rabbitmqctl add_vhost /zenoss
sudo rabbitmqctl set_permissions -p /zenoss zenoss '.*' '.*' '.*'
sudo chmod 777 /home/zenoss/.bashrc
sudo echo 'export ZENHOME=/usr/local/zenoss' >> /home/zenoss/.bashrc
sudo echo 'export PYTHONPATH=/usr/local/zenoss/lib/python' >> /home/zenoss/.bashrc
sudo echo 'export PATH=/usr/local/zenoss/bin:$PATH' >> /home/zenoss/.bashrc
sudo echo 'export INSTANCE_HOME=$ZENHOME' >> /home/zenoss/.bashrc
sudo chmod 644 /home/zenoss/.bashrc

echo "MySQL Adjustments"
sudo echo '#This is commented out as it is the default parameter' >> /etc/mysql/my.cnf
sudo echo '#max_allowed_packet=16M' >> /etc/mysql/my.cnf
sudo echo 'innodb_buffer_pool_size=256M' >> /etc/mysql/my.cnf
sudo echo 'innodb_additional_mem_pool_size=20M' >> /etc/mysql/my.cnf

echo "SNMP Adjustments"
sudo sed -i 's/mibs/#mibs/g' /etc/snmp/snmp.conf

echo "Java Adjustments"
sudo update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk1.6.0_34/bin/javac 1
sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk1.6.0_34/bin/java 1

echo "Zenoss Installation Preparation (may take a few minutes)"
sudo svn --quiet co http://dev.zenoss.org/svn/tags/zenoss-4.2.0/inst /home/zenoss/zenoss-inst
sudo chown -R zenoss:zenoss /home/zenoss/zenoss-inst
echo "###############################################
echo "##        Ready for install!!"
echo "##        Follow the Instructions below"
echo "##"
echo "##        sudo su zenoss"
echo "##        cd /home/zenoss/zenoss-inst"
echo "##        ./install.sh"
echo ""
echo "##        Zenoss Post Installation Adjustments"
echo "##        Nmap setuid fix"
echo "##        sudo chown root:zenoss /usr/local/zenoss/bin/nmap && sudo chmod u+s /usr/local/zenoss/bin/nmap"
echo "###############################################