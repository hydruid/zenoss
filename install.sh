#!/bin/bash
####################################################
#
# A simple script to auto-install Zenoss Core 4.2
# simple script to auto-install Zenoss Core 4.2
#
# This script should be run on a base install of
# Ubuntu 12.04 x64
#
# Status: Functional...still working on automation
# Version: 04 - Beta01
#
###################################################

# Check for Zenoss symlink
if [ -L /usr/local/zenoss ]; then
        echo "/usr/local/zenoss appears to be a symlink. Please remove and re-run this script."
        exit 1
fi

search=$(dpkg --list | egrep -i "mysql-")
if [ "" == "$search" ];
        then
                echo "No MySQL Packages found...."
                echo "Installing Distro MySQL Packages...."
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
                echo "No Openjdk Packages found...."
                echo "Installing Oracle JDK1.6_34u...."
                        if [ -f jdk-6u34-linux-x64.bin ];
                                then
                                        echo "Oracle JDK1.6_u34 .bin found"
					echo "chmod u+x jdk-6u34-linux-x64.bin"
					echo "sudo ./jdk-6u34-linux-x64.bin"
					echo "sudo mkdir /usr/lib/jvm/"
					echo "sudo mv jdk1.6.0_34 /usr/lib/jvm/"
					echo "sudo update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk1.6.0_34/bin/javac 1"
					echo "sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk1.6.0_34/bin/java 1"
				else
                                        echo ""
                                        echo ""
                                        echo "#######Error:#######"
                                        echo "Oracle JDK1.6_u34 .bin not found "
                                        echo "Please Download jdk-6u34-linux-x64.bin from the below link"
                                        echo "http://www.oracle.com/technetwork/java/javasebusiness/downloads/java-archive-downloads-javase6-419409.html#jdk-6u34-oth-JPR "
                                        echo "Save it in the same directory as install.sh"
                                        exit;
                        fi
        else
                echo "It appears that the distro-supplied version of OpenJDK is at least partially installed."
                echo "Please remove these packages, as well as their dependencies, and then retry this script:"
                echo "$ sudo dpkg --list | grep openjdk"
                echo ""
                echo "Example command to remove openjdk-* packages"
                echo "$ sudo apt-get purge openjdk*"
                exit
fi

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
echo "##        Ready for install!!"
echo "##        Follow the Instructions below"
echo "##"
echo "##        Modify file - sudo vi /home/zenoss/.bashrc"
echo "##        export ZENHOME=/usr/local/zenoss"
echo "##        export PYTHONPATH=$ZENHOME/lib/python"
echo "##        export PATH=$ZENHOME/bin:$PATH"
echo "##        export INSTANCE_HOME=$ZENHOME"
echo "##        Modify file - sudo vi /etc/mysql/my.cnf"
echo "##        max_allowed_packet=16M"
echo "##        innodb_buffer_pool_size=256M"
echo "##        innodb_additional_mem_pool_size=20M"
echo "##        Modify file - sudo vi /etc/snmp/snmp.conf"
echo "##        #mibs :"
echo "##"
echo "##        sudo su zenoss"
echo "##        cd /home/zenoss/zenoss-inst"
echo "##        ./install.sh"

echo "Zenoss Post Installation configurations"
# Nmap setuid fix
sudo chown root:zenoss /usr/local/zenoss/bin/nmap && sudo chmod u+s /usr/local/zenoss/bin/nmap
