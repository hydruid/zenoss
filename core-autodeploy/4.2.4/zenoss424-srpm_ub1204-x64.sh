#!/bin/bash
#
# Version: 02b
# Status: Not functional...under heavy development
#
# Zenoss: Core 4.2.4 (From SRPM)
# OS: Ubuntu 12.04 x64
#

# Warning about script still being under development
echo "####################################################"
read -p "This script is still a work and progress, it will not fully install Zenoss....you shouldn't use this unless you know what you're doing!"
read -p "This script will take a long time to complete..."
read -p "If you are really sure, press [Enter] to continue..."
echo "####################################################"

# Update package list and install any updates
echo "Step 01: Installing Ubuntu updates..."
apt-get update > /dev/null && apt-get dist-upgrade -y > /dev/null


# Verify OS/Arch compatibility, ensure not running as the 'zenoss' user
echo "Step 02: Run System Checks..."
if grep -Fxq "Ubuntu 12.04.2 LTS" /etc/issue.net
	then	echo "...Correct OS detected."
		if uname -m | grep -Fxq "x86_64"
			then	echo "...Correct Arch detected"
			else	echo "...Incorrect Arch detected...stopped script" && exit 0
                fi
	else	echo "...Incorrect OS detected...stopping script" && exit 0
fi
if [ `whoami` != 'zenoss' ]; then	echo "...All system checks passed"
	else	echo "...This script should not be ran by the zenoss user" && exit 0
fi


# Install required packages
echo "Step 03: Install Dependencies"
apt-get install python-software-properties -y && echo | add-apt-repository ppa:webupd8team/java
apt-get update && apt-get install rrdtool mysql-server mysql-client mysql-common libmysqlclient-dev rabbitmq-server nagios-plugins erlang subversion autoconf swig unzip zip g++ libssl-dev maven libmaven-compiler-plugin-java build-essential libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev oracle-java6-installer python-twisted python-gnutls python-twisted-web python-samba libsnmp-base snmp-mibs-downloader bc rpm2cpio memcached libncurses5 libncurses5-dev libreadline6-dev libreadline6 -y


# Setup the 'zenoss' user, configure rabbit, apply misc. adjustments 
echo "Step 04: Zenoss user setup and misc package adjustments"
useradd -m -U -s /bin/bash zenoss > /dev/null 2>/dev/null
mkdir /usr/local/zenoss > /dev/null 2>/dev/null
chown -R zenoss:zenoss /usr/local/zenoss
rabbitmqctl add_user zenoss zenoss > /dev/null 2>/dev/null
rabbitmqctl add_vhost /zenoss > /dev/null 2>/dev/null
rabbitmqctl set_permissions -p /zenoss zenoss '.*' '.*' '.*' > /dev/null 2>/dev/null
chmod 777 /home/zenoss/.bashrc
echo 'export ZENHOME=/usr/local/zenoss' >> /home/zenoss/.bashrc
echo 'export PYTHONPATH=/usr/local/zenoss/lib/python' >> /home/zenoss/.bashrc
echo 'export PATH=/usr/local/zenoss/bin:$PATH' >> /home/zenoss/.bashrc
echo 'export INSTANCE_HOME=$ZENHOME' >> /home/zenoss/.bashrc
chmod 644 /home/zenoss/.bashrc
echo '#max_allowed_packet=16M' >> /etc/mysql/my.cnf
echo 'innodb_buffer_pool_size=256M' >> /etc/mysql/my.cnf
echo 'innodb_additional_mem_pool_size=20M' >> /etc/mysql/my.cnf
sed -i 's/mibs/#mibs/g' /etc/snmp/snmp.conf


# Download the zenoss SRPM 
echo "Step 05: Download the Zenoss install"
#mkdir /home/zenoss/zenoss424-srpm_install
#cd /home/zenoss/zenoss424-srpm_install
#wget http://iweb.dl.sourceforge.net/project/zenoss/zenoss-4.2/zenoss-4.2.4/zenoss_core-4.2.4.el6.src.rpm
#rpm2cpio zenoss_core-4.2.4.el6.src.rpm | cpio -i --make-directories
#bunzip2 zenoss_core-4.2.4-1859.el6.x86_64.tar.bz2
#tar -xvf zenoss_core-4.2.4-1859.el6.x86_64.tar


# Install Zenoss Core 4.2.4 
echo "Step 06: Start the Zenoss install"
echo "...Install the rrdtool external lib"
apt-get install librrd-dev
cd /home/zenoss/zenoss424-srpm_install/zenoss_core-4.2.4/externallibs/
tar zxvf rrdtool-1.4.7.tar.gz
cd /home/zenoss/zenoss424-srpm_install/zenoss_core-4.2.4/externallibs/rrdtool-1.4.7
./configure
make
make install
echo "...Install Zenoss"
cd /home/zenoss/zenoss424-srpm_install/zenoss_core-4.2.4/
wget https://raw.github.com/hydruid/zenoss/master/core-autodeploy/4.2.4/misc/variables.sh
wget https://raw.github.com/hydruid/zenoss/master/core-autodeploy/4.2.4/misc/rrdclean.sh
wget http://www.rabbitmq.com/releases/rabbitmq-server/v3.1.3/rabbitmq-server_3.1.3-1_all.deb
dpkg -i rabbitmq-server_3.1.3-1_all.deb
./configure
make
make clean
cp /home/zenoss/zenoss424-srpm_install/zenoss_core-4.2.4/mkzenossinstance.sh /home/zenoss/zenoss424-srpm_install/zenoss_core-4.2.4/mkzenossinstance.sh
su - root -c "sed -i 's:# configure to generate the uplevel mkzenossinstance.sh script.:# configure to generate the uplevel mkzenossinstance.sh script.\n#\n#Custom Ubuntu Variables\n. variables.sh:g' /home/zenoss/zenoss424-srpm_install/zenoss_core-4.2.4/mkzenossinstance.sh"
./mkzenossinstance.sh
./mkzenossinstance.sh

# Still some stuff left to do :)
