#!/bin/bash

#####################################################
# Version: 03b                                       #
# Status: Functional....automation improved          #
#                                                    #
# Zenoss Version: Core 4.2.3                         #
# OS: Ubuntu 12.04 x64                               #
######################################################

#Step-01: Determine OS and Arch
if grep -Fxq "Ubuntu 12.04.1 LTS" /etc/issue.net 
    then
	echo "Correct OS detected..."
    else
	echo "Incorrect OS detected...stopping script"
	exit 0
fi
if grep -FqR "Release amd64" /etc/apt/sources.list
    then
        echo "Correct Arch detected...\n"
    else
        echo "Incorrect Arch detected...stopping script"
        exit 0
fi
if whoami | grep zenoss
    then
        echo "This script should not be ran as the zenoss user..."
        echo "You should run it as your normal admin user..."
        exit 0
    else
        echo ""
fi

#Step-02: Install Dependencies
add-apt-repository ppa:webupd8team/java
apt-get update
apt-get install rrdtool mysql-server mysql-client mysql-common libmysqlclient-dev rabbitmq-server nagios-plugins erlang subversion autoconf swig unzip zip g++ libssl-dev maven libmaven-compiler-plugin-java build-essential libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev oracle-java6-installer python-twisted python-gnutls python-twisted-web python-samba

#Step-03: Zenoss User Setup 
if [ -f /home/zenoss/.bashrc ];
        then
                echo "Zenoss user already exists...skipping"
        else
                useradd -m -U -s /bin/bash zenoss
                mkdir /usr/local/zenoss
                chown -R zenoss:zenoss /usr/local/zenoss
                rabbitmqctl add_user zenoss zenoss
                rabbitmqctl add_vhost /zenoss
                rabbitmqctl set_permissions -p /zenoss zenoss '.*' '.*' '.*'
                chmod 777 /home/zenoss/.bashrc
                echo 'export ZENHOME=/usr/local/zenoss' >> /home/zenoss/.bashrc
                echo 'export PYTHONPATH=/usr/local/zenoss/lib/python' >> /home/zenoss/.bashrc
                echo 'export PATH=/usr/local/zenoss/bin:$PATH' >> /home/zenoss/.bashrc
                echo 'export INSTANCE_HOME=$ZENHOME' >> /home/zenoss/.bashrc
                chmod 644 /home/zenoss/.bashrc
fi

#Step-04: Misc Adjustments for MySQL, SNMP, and Java
#MySQL
echo '#max_allowed_packet=16M' >> /etc/mysql/my.cnf
echo 'innodb_buffer_pool_size=256M' >> /etc/mysql/my.cnf
echo 'innodb_additional_mem_pool_size=20M' >> /etc/mysql/my.cnf
#SNMP
sed -i 's/mibs/#mibs/g' /etc/snmp/snmp.conf

#Step-05: Download Zenoss Install 
if [ -f /home/zenoss/zenoss-inst/CHANGES.txt ];
        then
                echo "Zenoss install already exists...skipping\n"
        else
		sudo svn --quiet co http://dev.zenoss.org/svn/tags/zenoss-4.2.3/inst /home/zenoss/zenoss-inst
		sudo chown -R zenoss:zenoss /home/zenoss/zenoss-inst
fi
echo "###############################################"
echo "## Ready for install!!"
echo "## Follow the Instructions below"
echo "##"
echo "## Zenoss Install"
echo "##   sudo su zenoss"
echo "##   cd /home/zenoss/zenoss-inst"
echo "##   ./install.sh"
echo "##"
echo "## Zenoss Post Installation Adjustments"
echo "## (Run these commands as a non zenoss user)"
echo "##   Nmap, Zensocket, and Pyraw setuid fix"
echo "##   sudo chown root:zenoss /usr/local/zenoss/bin/nmap && sudo chmod u+s /usr/local/zenoss/bin/nmap"
echo "##   sudo chown root:zenoss /usr/local/zenoss/bin/zensocket && sudo chmod u+s /usr/local/zenoss/bin/zensocket"
echo "##   sudo chown root:zenoss /usr/local/zenoss/bin/pyraw && sudo chmod u+s /usr/local/zenoss/bin/pyraw"
echo "###############################################"
