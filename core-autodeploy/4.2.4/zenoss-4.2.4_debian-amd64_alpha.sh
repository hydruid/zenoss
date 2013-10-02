#!/bin/bash
#######################################################
# Version: 01a Alpha - 02                             #
#  Status: Not Functional                             #
#   Notes: Various daemons are broken                 #
#  Zenoss: Core 4.2.4 & ZenPacks (v1897)              #
#      OS: Debian 7 x86_64                            #
#######################################################

# Beginning Script Message
echo && echo "Welcome to the Zenoss 4.2.4 core-autodeploy script for Debian!"
echo "Blog Post: http://hydruid-blog.com/?p=343" && echo && sleep 5

# Update Ubuntu
apt-get update && apt-get dist-upgrade -y && apt-get autoremove -y

# Setup zenoss user and build environment
useradd -m -U -s /bin/bash zenoss
chmod 777 /home/zenoss/.bashrc
echo 'export ZENHOME=/usr/local/zenoss' >> /home/zenoss/.bashrc
echo 'export PYTHONPATH=/usr/local/zenoss/lib/python' >> /home/zenoss/.bashrc
echo 'export PATH=/usr/local/zenoss/bin:$PATH' >> /home/zenoss/.bashrc
echo 'export INSTANCE_HOME=$ZENHOME' >> /home/zenoss/.bashrc
chmod 644 /home/zenoss/.bashrc
mkdir /home/zenoss/zenoss424-srpm_install
wget -N https://raw.github.com/hydruid/zenoss/master/core-autodeploy/4.2.4/misc/variables.sh -P /home/zenoss/zenoss424-srpm_install/
. /home/zenoss/zenoss424-srpm_install/variables.sh
mkdir $ZENHOME && chown -cR zenoss:zenoss $ZENHOME

# OS compatibility tests
detect-os2 && detect-arch && detect-user

# Install Package Dependencies
apt-get install python-software-properties -y && sleep 1
echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
apt-get update
apt-get install rrdtool libmysqlclient-dev nagios-plugins erlang subversion autoconf swig unzip zip g++ libssl-dev maven libmaven-compiler-plugin-java build-essential libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev oracle-java7-installer python-twisted python-gnutls python-twisted-web python-samba libsnmp-base bc rpm2cpio memcached libncurses5 libncurses5-dev libreadline6-dev libreadline6 librrd-dev python-setuptools python-dev erlang-nox smistrip -y
wget -N http://ftp.us.debian.org/debian/pool/non-free/s/snmp-mibs-downloader/snmp-mibs-downloader_1.1_all.deb
dpkg -i snmp-mibs-downloader_1.1_all.deb
export DEBIAN_FRONTEND=noninteractive
apt-get install mysql-server mysql-client mysql-common -y
mysql-conn_test

# Download Zenoss SRPM and extract it
wget -N http://softlayer-dal.dl.sourceforge.net/project/zenoss/zenoss-4.2/zenoss-4.2.4/4.2.4-1897/zenoss_core-4.2.4-1897.el6.src.rpm -P $INSTALLDIR && cd $INSTALLDIR
rpm2cpio zenoss_core-4.2.4-1897.el6.src.rpm | cpio -i --make-directories
bunzip2 zenoss_core-4.2.4-1897.el6.x86_64.tar.bz2 && tar -xvf zenoss_core-4.2.4-1897.el6.x86_64.tar
chown -R zenoss:zenoss $INSTALLDIR

# Install Zenoss Core
tar zxvf $INSTALLDIR/zenoss_core-4.2.4/externallibs/rrdtool-1.4.7.tar.gz -C $INSTALLDIR/ && cd $INSTALLDIR/rrdtool-1.4.7
./configure --prefix=$ZENHOME
make && make install
wget -N http://dev.zenoss.org/svn/tags/zenoss-4.2.4/inst/rrdclean.sh -P $INSTALLDIR/zenoss_core-4.2.4/ && cd $INSTALLDIR/zenoss_core-4.2.4/
./configure 2>&1 | tee log-configure.log
make 2>&1 | tee log-make.log
make clean 2>&1 | tee log-make_clean.log
cp mkzenossinstance.sh mkzenossinstance.sh.orig
su - root -c "sed -i 's:# configure to generate the uplevel mkzenossinstance.sh script.:# configure to generate the uplevel mkzenossinstance.sh script.\n#\n#Custom Ubuntu Variables\n. /home/zenoss/zenoss424-srpm_install/variables.sh:g' $INSTALLDIR/zenoss_core-4.2.4/mkzenossinstance.sh"
./mkzenossinstance.sh 2>&1 | tee log-mkzenossinstance_a.log
./mkzenossinstance.sh 2>&1 | tee log-mkzenossinstance_b.log
chown -R zenoss:zenoss $ZENHOME

echo "...stopping here"
echo "...this section still under development"
exit 0
