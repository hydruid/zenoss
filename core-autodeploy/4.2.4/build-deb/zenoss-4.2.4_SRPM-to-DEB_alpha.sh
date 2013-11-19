#!/bin/bash
#######################################################
# Version: 01a Alpha - 03                             #
#  Status: Not Functional                             #
#   Notes: Focusing on automating DEB builds          #
#  Zenoss: Core 4.2.4 & ZenPacks (v1897)              #
#      OS: Ubuntu 12.04 LTS x86_64                    #
#######################################################

# Beginning Script Message
echo && echo "Welcome to the Zenoss 4.2.4 SRPM to DEB script for Ubuntu!"
echo "Blog Post: http://hydruid-blog.com/?p=343" && echo 
echo "Notes: All feedback and suggestions are appreciated." && echo && sleep 5

# Installer variables
## Home path for the zenoss user
zenosshome="/home/zenoss"
## Download Directory
downdir="/tmp"

# Update Ubuntu
apt-get update && apt-get dist-upgrade -y && apt-get autoremove -y

# Setup zenoss user and build environment
useradd -m -U -s /bin/bash zenoss
chmod 777 $zenosshome/.bashrc
echo 'export ZENHOME=/usr/local/zenoss' >> $zenosshome/.bashrc
echo 'export PYTHONPATH=/usr/local/zenoss/lib/python' >> $zenosshome/.bashrc
echo 'export PATH=/usr/local/zenoss/bin:$PATH' >> $zenosshome/.bashrc
echo 'export INSTANCE_HOME=$ZENHOME' >> $zenosshome/.bashrc
chmod 644 $zenosshome/.bashrc
mkdir $zenosshome/zenoss424-srpm_install
wget --no-check-certificate -N https://raw.github.com/hydruid/zenoss/master/core-autodeploy/4.2.4/misc/variables.sh -P $zenosshome/zenoss424-srpm_install/
. $zenosshome/zenoss424-srpm_install/variables.sh
mkdir $ZENHOME && chown -cR zenoss:zenoss $ZENHOME

# OS compatibility tests
detect-os2 && detect-arch && detect-user
if grep -Fxq "Ubuntu 12.04.3 LTS" /etc/issue.net
        then    echo "...Correct OS detected."
else    echo "...Incorrect OS detected, this build script requires Ubuntu 12.04 LTS" && exit 0
fi

# Install Package Dependencies
## Java PPA
apt-get install python-software-properties -y && sleep 1
echo | add-apt-repository ppa:webupd8team/java && sleep 1 && apt-get update
## Install Packages
apt-get install rrdtool libmysqlclient-dev nagios-plugins erlang subversion autoconf swig unzip zip g++ libssl-dev maven libmaven-compiler-plugin-java build-essential libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev oracle-java7-installer python-twisted python-gnutls python-twisted-web python-samba libsnmp-base snmp-mibs-downloader bc rpm2cpio memcached libncurses5 libncurses5-dev libreadline6-dev libreadline6 librrd-dev python-setuptools python-dev erlang-nox -y
pkg-fix
## MySQL Packages
export DEBIAN_FRONTEND=noninteractive
apt-get install mysql-server mysql-client mysql-common -y
mysql-conn_test
pkg-fix

# Download the Zenoss SRPM 
wget -N http://softlayer-dal.dl.sourceforge.net/project/zenoss/zenoss-4.2/zenoss-4.2.4/4.2.4-1897/zenoss_core-4.2.4-1897.el6.src.rpm -P $zenosshome/zenoss424-srpm_install/
cd $zenosshome/zenoss424-srpm_install/ && rpm2cpio zenoss_core-4.2.4-1897.el6.src.rpm | cpio -i --make-directories
bunzip2 zenoss_core-4.2.4-1897.el6.x86_64.tar.bz2 && tar -xvf zenoss_core-4.2.4-1897.el6.x86_64.tar

# Install the Zenoss SRPM
apt-get install librrd-dev -y
tar zxvf /home/zenoss/zenoss424-srpm_install/zenoss_core-4.2.4/externallibs/rrdtool-1.4.7.tar.gz && cd rrdtool-1.4.7/
./configure --prefix=/usr/local/zenoss
make && make install
cd /home/zenoss/zenoss424-srpm_install/zenoss_core-4.2.4/
wget http://dev.zenoss.org/svn/tags/zenoss-4.2.4/inst/rrdclean.sh
## Rabbit install and config
wget -N http://www.rabbitmq.com/releases/rabbitmq-server/v3.2.1/rabbitmq-server_3.2.1-1_all.deb -P $downdir/
dpkg -i $downdir/rabbitmq-server_3.2.1-1_all.deb
chown -R zenoss:zenoss $ZENHOME
rabbitmqctl add_user zenoss zenoss
rabbitmqctl add_vhost /zenoss
rabbitmqctl set_permissions -p /zenoss zenoss '.*' '.*' '.*'
./configure 2>&1 | tee log-configure.log
make 2>&1 | tee log-make.log
make clean 2>&1 | tee log-make_clean.log
cp mkzenossinstance.sh mkzenossinstance.sh.orig
su - root -c "sed -i 's:# configure to generate the uplevel mkzenossinstance.sh script.:# configure to generate the uplevel mkzenossinstance.sh script.\n#\n#Custom Ubuntu Variables\n. variables.sh:g' /home/zenoss/zenoss424-srpm_install/zenoss_core-4.2.4/mkzenossinstance.sh"
read -p "If you set a password for the root MySQL User, you will have to manually input the password into: /usr/local/zenoss/etc/global.conf (I will automate this on the next round, there are 2 entries for the password)"
./mkzenossinstance.sh 2>&1 | tee log-mkzenossinstance_a.log
./mkzenossinstance.sh 2>&1 | tee log-mkzenossinstance_b.log
chown -R zenoss:zenoss /usr/local/zenoss

# Install the Core ZenPacks
wget -N http://softlayer-dal.dl.sourceforge.net/project/zenoss/zenoss-4.2/zenoss-4.2.4/4.2.4-1897/zenoss_core-4.2.4-1897.el6.x86_64.rpm -P /home/zenoss/zenoss424-srpm_install/

echo "...Still a few more steps to go, check back later!"
exit 0

# ZenPack Install
# MySQL Dump
# Install FPM
# Create DEB


# Install the Core ZenPacks
echo "Step 07: Install the Core ZenPacks"
rm -fr /home/zenoss/rpm > /dev/null 2>/dev/null && rm -fr /home/zenoss/*.egg > /dev/null 2>/dev/null
mkdir /home/zenoss/rpm && cd /home/zenoss/rpm
wget http://superb-dca2.dl.sourceforge.net/project/zenoss/zenoss-4.2/zenoss-4.2.4/zenoss_core-4.2.4.el6.x86_64.rpm
rpm2cpio zenoss_core-4.2.4.el6.x86_64.rpm | sudo cpio -ivd ./opt/zenoss/packs/*.*
cp /home/zenoss/rpm/opt/zenoss/packs/*.egg /home/zenoss/
chown -R zenoss:zenoss /home/zenoss
rm /home/zenoss/zenpack-helper.sh > /dev/null 2>/dev/null && touch /home/zenoss/zenpack-helper.sh
echo '#!/bin/bash' >> /home/zenoss/zenpack-helper.sh
echo 'ZENHOME=/usr/local/zenoss' >> /home/zenoss/zenpack-helper.sh
echo 'export ZENHOME=/usr/local/zenoss' >> /home/zenoss/zenpack-helper.sh
echo 'PYTHONPATH=/usr/local/zenoss/lib/python' >> /home/zenoss/zenpack-helper.sh
echo 'PATH=/usr/local/zenoss/bin:$PATH' >> /home/zenoss/zenpack-helper.sh
echo 'INSTANCE_HOME=$ZENHOME' >> /home/zenoss/zenpack-helper.sh
echo '/usr/local/zenoss/bin/zenoss restart' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.PySamba-1.0.2-py2.7-linux-x86_64.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.WindowsMonitor-1.0.8-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.ActiveDirectory-2.1.0-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.ApacheMonitor-2.1.3-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.DellMonitor-2.2.0-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.DeviceSearch-1.2.0-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.DigMonitor-1.1.0-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.DnsMonitor-2.1.0-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.EsxTop-1.1.0-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.FtpMonitor-1.1.0-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.HPMonitor-2.1.0-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.HttpMonitor-2.1.0-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.IISMonitor-2.0.2-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.IRCDMonitor-1.1.0-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.JabberMonitor-1.1.0-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.LDAPMonitor-1.4.0-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.LinuxMonitor-1.2.1-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.MSExchange-2.0.4-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.MSMQMonitor-1.2.1-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.MSSQLServer-2.0.3-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.MySqlMonitor-2.2.0-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.NNTPMonitor-1.1.0-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.NtpMonitor-2.2.0-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.PythonCollector-1.0.1-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.WBEM-1.0.0-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.WindowsMonitor-1.0.8-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.XenMonitor-1.1.0-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.ZenJMX-3.9.5-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'zenpack --install ZenPacks.zenoss.ZenossVirtualHostMonitor-2.4.0-py2.7.egg' >> /home/zenoss/zenpack-helper.sh
echo 'easy_install readline' >> /home/zenoss/zenpack-helper.sh
echo '/usr/local/zenoss/bin/zenoss restart' >> /home/zenoss/zenpack-helper.sh
su - zenoss -c "/bin/sh /home/zenoss/zenpack-helper.sh"
