#!/bin/bash
#######################################################
# Version: 01b Alpha - 02                             #
#  Status: Not Functional                             #
#   Notes: zeneventd won't start...python segfault    #
#  Zenoss: Core 4.2.4 & ZenPacks                      #
#      OS: Ubuntu 12.04.2 x86_64                      #
#######################################################

# Beginning Script Message
echo && echo "Welcome to the Zenoss 4.2.4 core-autodeploy script for Ubuntu!"
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
wget http://security.ubuntu.com/ubuntu/pool/main/e/eglibc/libc-bin_2.15-0ubuntu10.2_amd64.deb
dpkg -i libc-bin_2.15-0ubuntu10.2_amd64.deb
sudo apt-mark hold libc-bin
apt-get install python-software-properties -y && sleep 1
echo | add-apt-repository ppa:webupd8team/java && sleep 1 && apt-get update
apt-get install rrdtool libmysqlclient-dev nagios-plugins erlang subversion autoconf swig unzip zip g++ libssl-dev maven libmaven-compiler-plugin-java build-essential libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev oracle-java7-installer python-twisted python-gnutls python-twisted-web python-samba libsnmp-base snmp-mibs-downloader bc rpm2cpio memcached libncurses5 libncurses5-dev libreadline6-dev libreadline6 librrd-dev python-setuptools python-dev erlang-nox -y
export DEBIAN_FRONTEND=noninteractive
apt-get install mysql-server mysql-client mysql-common -y
mysql-conn_test

# Rabbit install and config
wget -N http://www.rabbitmq.com/releases/rabbitmq-server/v3.1.3/rabbitmq-server_3.1.3-1_all.deb -P /home/zenoss/zenoss424-srpm_install/
dpkg -i /home/zenoss/zenoss424-srpm_install/rabbitmq-server_3.1.3-1_all.deb
chown -R zenoss:zenoss $ZENHOME
rabbitmqctl add_user zenoss zenoss
rabbitmqctl add_vhost /zenoss
rabbitmqctl set_permissions -p /zenoss zenoss '.*' '.*' '.*'

# Download Zenoss SRPM and extract it
wget -N http://iweb.dl.sourceforge.net/project/zenoss/zenoss-4.2/zenoss-4.2.4/zenoss_core-4.2.4.el6.src.rpm -P $INSTALLDIR && cd $INSTALLDIR
rpm2cpio zenoss_core-4.2.4.el6.src.rpm | cpio -i --make-directories
bunzip2 zenoss_core-4.2.4-1859.el6.x86_64.tar.bz2 && tar -xvf zenoss_core-4.2.4-1859.el6.x86_64.tar
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

# Install Zenoss Core Zenpacks
mkdir $INSTALLDIR/ZenPacks && cd $INSTALLDIR/ZenPacks
wget -N http://superb-dca2.dl.sourceforge.net/project/zenoss/zenoss-4.2/zenoss-4.2.4/zenoss_core-4.2.4.el6.x86_64.rpm -P $INSTALLDIR/ZenPacks
rpm2cpio zenoss_core-4.2.4.el6.x86_64.rpm | sudo cpio -ivd ./opt/zenoss/packs/*.*
wget -N https://raw.github.com/hydruid/zenoss/master/core-autodeploy/4.2.4/misc/zenpack-helper.sh -P $INSTALLDIR/ZenPacks/opt/zenoss/packs
chown -R zenoss:zenoss /home/zenoss
su - zenoss -c "cd $INSTALLDIR/ZenPacks/opt/zenoss/packs && /bin/sh zenpack-helper.sh"
easy_install readline

# Post Install Tweaks
echo 'watchdog True' >> $ZENHOME/etc/zenwinperf.conf
touch $ZENHOME/var/Data.fs
cp $ZENHOME/bin/zenoss /etc/init.d/zenoss
su - root -c "sed -i 's:# License.zenoss under the directory where your Zenoss product is installed.:# License.zenoss under the directory where your Zenoss product is installed.\n#\n#Custom Ubuntu Variables\nexport ZENHOME=$ZENHOME\nexport RRDCACHED=$ZENHOME/bin/rrdcached:g' /etc/init.d/zenoss"
update-rc.d zenoss defaults && sleep 2
chown -c root:zenoss /usr/local/zenoss/bin/pyraw
chown -c root:zenoss /usr/local/zenoss/bin/zensocket
chown -c root:zenoss /usr/local/zenoss/bin/nmap
chmod -c 04750 /usr/local/zenoss/bin/pyraw
chmod -c 04750 /usr/local/zenoss/bin/zensocket
chmod -c 04750 /usr/local/zenoss/bin/nmap
wget -N https://raw.github.com/hydruid/zenoss/master/core-autodeploy/4.2.4/misc/secure_zenoss_ubuntu.sh -P $ZENHOME/bin
chown -c zenoss:zenoss $ZENHOME/bin/secure_zenoss_ubuntu.sh && chmod -c 0700 $ZENHOME/bin/secure_zenoss_ubuntu.sh
su -l -c "$ZENHOME/bin/secure_zenoss_ubuntu.sh" zenoss
echo '#max_allowed_packet=16M' >> /etc/mysql/my.cnf
echo 'innodb_buffer_pool_size=256M' >> /etc/mysql/my.cnf
echo 'innodb_additional_mem_pool_size=20M' >> /etc/mysql/my.cnf
sed -i 's/mibs/#mibs/g' /etc/snmp/snmp.conf

# End of Script Message
FINDIP=`ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
echo && echo "The Zenoss 4.2.4 core-autodeploy script for Ubuntu is complete!!!" && echo
echo "Browse to $FINDIP:8080 to access your new Zenoss install."
echo "The default login is:"
echo "  username: admin"
echo "  password: zenoss"
