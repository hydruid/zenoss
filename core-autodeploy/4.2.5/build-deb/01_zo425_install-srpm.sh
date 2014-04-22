#!/bin/bash
##########################################
# Version: 01b
#  Status: Functional
#   Notes: Updated for 4.2.5 
#  Zenoss: Core 4.2.5 (v2070) + ZenPacks
#      OS: Ubuntu 12.04 64-Bit
##########################################

# Beginning Script Message
echo && echo "Welcome to the Zenoss 4.2.5 SRPM to DEB script for Ubuntu!"
echo "Blog Post: http://hydruid-blog.com/?p=710" && echo 
echo "Notes: All feedback and suggestions are appreciated." && echo && sleep 5

# Installer variables
ZENOSSHOME="/home/zenoss"
DOWNDIR="/tmp"
ZVER="425"
ZVERb="4.2.5"
ZVERc="2108"

# Update Ubuntu
apt-get update && apt-get dist-upgrade -y && apt-get autoremove -y

# Setup zenoss user and build environment
useradd -m -U -s /bin/bash zenoss
chmod 777 $ZENOSSHOME/.bashrc
echo 'export ZENHOME=/usr/local/zenoss' >> $ZENOSSHOME/.bashrc
echo 'export PYTHONPATH=/usr/local/zenoss/lib/python' >> $ZENOSSHOME/.bashrc
echo 'export PATH=/usr/local/zenoss/bin:$PATH' >> $ZENOSSHOME/.bashrc
echo 'export INSTANCE_HOME=$ZENHOME' >> $ZENOSSHOME/.bashrc
echo 'export PATH=/opt/zenup/bin:$PATH' >> $ZENOSSHOME/.bashrc
chmod 644 $ZENOSSHOME/.bashrc
mkdir $ZENOSSHOME/zenoss$ZVER-srpm_install
wget --no-check-certificate -N https://raw.github.com/hydruid/zenoss/master/core-autodeploy/$ZVERb/misc/variables.sh -P $ZENOSSHOME/zenoss$ZVER-srpm_install/
. $ZENOSSHOME/zenoss$ZVER-srpm_install/variables.sh
mkdir $ZENHOME && chown -cR zenoss:zenoss $ZENHOME

# OS compatibility tests
detect-os && detect-arch && detect-user
if grep -Fxq "Ubuntu 12.04.4 LTS" /etc/issue.net
        then    echo "...Correct OS detected."
else    echo "...Incorrect OS detected, this build script requires Ubuntu 12.04 LTS" && sleep 15
fi

# Install Package Dependencies
apt-get install python-software-properties -y && sleep 1
echo | add-apt-repository ppa:webupd8team/java && sleep 1 && apt-get update
apt-get install rrdtool libmysqlclient-dev nagios-plugins erlang subversion autoconf swig unzip zip g++ libssl-dev maven libmaven-compiler-plugin-java build-essential libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev oracle-java7-installer python-twisted python-gnutls python-twisted-web python-samba libsnmp-base snmp-mibs-downloader bc rpm2cpio memcached libncurses5 libncurses5-dev libreadline6-dev libreadline6 librrd-dev python-setuptools python-dev erlang-nox -y
pkg-fix
export DEBIAN_FRONTEND=noninteractive
apt-get install mysql-server mysql-client mysql-common -y
mysql-conn_test
pkg-fix

# Download the Zenoss SRPM 
wget -N http://iweb.dl.sourceforge.net/project/zenoss/zenoss-rc/builds/$ZVERb-$ZVERc/zenoss_core-$ZVERb-$ZVERc.el6.src.rpm -P $ZENOSSHOME/zenoss$ZVER-srpm_install/
cd $ZENOSSHOME/zenoss$ZVER-srpm_install/ && rpm2cpio zenoss_core-$ZVERb-$ZVERc.el6.src.rpm | cpio -i --make-directories
bunzip2 zenoss_core-$ZVERb-$ZVERc.el6.x86_64.tar.bz2 && tar -xvf zenoss_core-$ZVERb-$ZVERc.el6.x86_64.tar

# Install the Zenoss SRPM
apt-get install librrd-dev -y
tar zxvf /home/zenoss/zenoss$ZVER-srpm_install/zenoss_core-$ZVERb/externallibs/rrdtool-1.4.7.tar.gz && cd rrdtool-1.4.7/
./configure --prefix=/usr/local/zenoss
make && make install
cd /home/zenoss/zenoss$ZVER-srpm_install/zenoss_core-$ZVERb/
wget http://dev.zenoss.org/svn/tags/zenoss-4.2.4/inst/rrdclean.sh
wget -N http://www.rabbitmq.com/releases/rabbitmq-server/v3.3.0/rabbitmq-server_3.3.0-1_all.deb -P $DOWNDIR/
dpkg -i $DOWNDIR/rabbitmq-server_3.3.0-1_all.deb
chown -R zenoss:zenoss $ZENHOME
rabbitmqctl add_user zenoss zenoss
rabbitmqctl add_vhost /zenoss
rabbitmqctl set_permissions -p /zenoss zenoss '.*' '.*' '.*'
./configure 2>&1 | tee log-configure.log
make 2>&1 | tee log-make.log
make clean 2>&1 | tee log-make_clean.log
cp $ZENOSSHOME/zenoss$ZVER-srpm_install/variables.sh $ZENOSSHOME/zenoss$ZVER-srpm_install/zenoss_core-$ZVERb/
cp mkzenossinstance.sh mkzenossinstance.sh.orig
su - root -c "sed -i 's:# configure to generate the uplevel mkzenossinstance.sh script.:# configure to generate the uplevel mkzenossinstance.sh script.\n#\n#Custom Ubuntu Variables\n. variables.sh:g' /home/zenoss/zenoss$ZVER-srpm_install/zenoss_core-$ZVERb/mkzenossinstance.sh"
./mkzenossinstance.sh 2>&1 | sudo tee log-mkzenossinstance_a.log
echo "...The above error is safe to ignore"
./mkzenossinstance.sh 2>&1 | sudo tee log-mkzenossinstance_b.log
chown -R zenoss:zenoss /usr/local/zenoss

# Download and extract the Core ZenPacks
wget -N http://softlayer-ams.dl.sourceforge.net/project/zenoss/zenoss-rc/builds/$ZVERb-$ZVERc/zenoss_core-$ZVERb-$ZVERc.el6.x86_64.rpm -P $DOWNDIR/
rpm2cpio $DOWNDIR/zenoss_core-$ZVERb-$ZVERc.el6.x86_64.rpm | sudo cpio -ivd ./opt/zenoss/packs/*.* && mv opt/ $DOWNDIR/

echo "...Script complete, move onto step 02"
exit 0

