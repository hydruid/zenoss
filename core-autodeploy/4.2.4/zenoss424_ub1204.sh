#!/bin/bash
#
# Version: 01c Beta
# Status: Not Functional...will be very soon!
#
# Zenoss: Core 4.2.4 & ZenPacks
# OS: Ubuntu 12.04 x64
#

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
read -p "...During the install please leave the password blank for the root MySQL user, Press ENTER to continue (will fix password issue soon)"
apt-get install python-software-properties -y && echo | add-apt-repository ppa:webupd8team/java
apt-get update && apt-get install rrdtool mysql-server mysql-client mysql-common libmysqlclient-dev rabbitmq-server nagios-plugins erlang subversion autoconf swig unzip zip g++ libssl-dev maven libmaven-compiler-plugin-java build-essential libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev oracle-java6-installer python-twisted python-gnutls python-twisted-web python-samba libsnmp-base snmp-mibs-downloader bc rpm2cpio memcached libncurses5 libncurses5-dev libreadline6-dev libreadline6 -y
mysql -u root -e "show databases;" 2>&1 | sudo tee /tmp/mysql.txt
if grep -Fxq "Database" /tmp/mysql.txt
        then    echo "...MySQL connection test successful."
        else    echo "...Mysql connection failed...make sure the password is blank for the root MySQL user." && exit 0
fi


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


PS3='###...Choose your install Type: '
options=("SRPM Install (under development)" "SVN Install (almost functional...best to choose this option for now)")
select opt in "${options[@]}"
do
case $opt in
        "SRPM Install (under development)")
		# Download the zenoss SRPM
		echo "Step 05: Download the Zenoss install"
		mkdir /home/zenoss/zenoss424-srpm_install
		cd /home/zenoss/zenoss424-srpm_install
		wget http://iweb.dl.sourceforge.net/project/zenoss/zenoss-4.2/zenoss-4.2.4/zenoss_core-4.2.4.el6.src.rpm
		rpm2cpio zenoss_core-4.2.4.el6.src.rpm | cpio -i --make-directories
		bunzip2 zenoss_core-4.2.4-1859.el6.x86_64.tar.bz2 && tar -xvf zenoss_core-4.2.4-1859.el6.x86_64.tar
		# Install Zenoss Core 4.2.4
		echo "Step 06: Start the Zenoss install"
		echo "...Install the rrdtool external lib"
		apt-get install librrd-dev -y
		tar zxvf /home/zenoss/zenoss424-srpm_install/zenoss_core-4.2.4/externallibs/rrdtool-1.4.7.tar.gz && cd rrdtool-1.4.7/
		./configure --prefix=/usr/local/zenoss
		make && make install
		cd /home/zenoss/zenoss424-srpm_install/zenoss_core-4.2.4/
		wget https://raw.github.com/hydruid/zenoss/master/core-autodeploy/4.2.4/misc/variables.sh
		wget http://dev.zenoss.org/svn/tags/zenoss-4.2.4/inst/rrdclean.sh
		wget http://www.rabbitmq.com/releases/rabbitmq-server/v3.1.3/rabbitmq-server_3.1.3-1_all.deb
		dpkg -i rabbitmq-server_3.1.3-1_all.deb
		./configure 2>&1 | tee log-configure.log
		make 2>&1 | tee log-make.log
		make clean 2>&1 | tee log-make_clean.log
		cp mkzenossinstance.sh mkzenossinstance.sh.orig
		su - root -c "sed -i 's:# configure to generate the uplevel mkzenossinstance.sh script.:# configure to generate the uplevel mkzenossinstance.sh script.\n#\n#Custom Ubuntu Variables\n. variables.sh:g' /home/zenoss/zenoss424-srpm_install/zenoss_core-4.2.4/mkzenossinstance.sh"
		read -p "If you set a password for the root MySQL User, you will have to manually input the password into: /usr/local/zenoss/etc/global.conf (I will automate this on the next round, there are 2 entries for the password)"
		./mkzenossinstance.sh 2>&1 | tee log-mkzenossinstance_a.log
		./mkzenossinstance.sh 2>&1 | tee log-mkzenossinstance_b.log
		chown -R zenoss:zenoss /usr/local/zenoss
	break
	;;
        "SVN Install (almost functional...best to choose this option for now)")
		# Download the zenoss SVN
		echo "Step 05: Download the Zenoss install"
		svn co http://dev.zenoss.org/svn/tags/zenoss-4.2.4 /home/zenoss/zenoss424_svn-install
		chown -R zenoss:zenoss /home/zenoss/zenoss424_svn-install
		# Install Zenoss Core 4.2.4
		echo "Step 06: Start the Zenoss install"
		apt-get install librrd-dev -y
		tar zxvf /home/zenoss/zenoss424_svn-install/inst/externallibs/rrdtool-1.4.7.tar.gz && cd rrdtool-1.4.7/
		./configure --prefix=/usr/local/zenoss
		make && make install
		wget http://www.rabbitmq.com/releases/rabbitmq-server/v3.1.3/rabbitmq-server_3.1.3-1_all.deb
		dpkg -i rabbitmq-server_3.1.3-1_all.deb
		ZENHOME=/usr/local/zenoss
		PYTHONPATH=/usr/local/zenoss/lib/python
		PATH=/usr/local/zenoss/bin:$PATH
		INSTANCE_HOME=$ZENHOME
		cd /home/zenoss/zenoss424_svn-install/inst
		wget https://raw.github.com/hydruid/zenoss/master/core-autodeploy/4.2.4/misc/variables.sh
		su - root -c "sed -i 's:# configure to generate the uplevel mkzenossinstance.sh script.:# configure to generate the uplevel mkzenossinstance.sh script.\n#\n#Custom Ubuntu Variables\n. variables.sh:g' /home/zenoss/zenoss424_svn-install/inst/mkzenossinstance.sh"
		su - root -c "sed -i 's:try ./mkzenossinstance.sh:su - zenoss -c /home/zenoss/zenoss424_svn-install/inst/mkzenossinstance.sh:g' /home/zenoss/zenoss424_svn-install/inst/install.sh"	
		./install.sh | sudo tee install.log
		chown -R zenoss:zenoss /usr/local/zenoss
		if grep -Fxq "Successfully installed Zenoss" /home/zenoss/zenoss424_svn-install/status.log
		        then    echo "...Zenoss build successful."
		        else    echo "...Zenoss build unsuccessful, errors detected...stopping the script" && exit 0
		fi
	break
	;;
        *) echo invalid option;;
esac
done


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


# Complete post installation adjustments
echo "Step 08: Post Installation Adjustments"
cp /usr/local/zenoss/bin/zenoss /etc/init.d/zenoss
touch /usr/local/zenoss/var/Data.fs && chown zenoss:zenoss /usr/local/zenoss/var/Data.fs
su - root -c "sed -i 's:# License.zenoss under the directory where your Zenoss product is installed.:# License.zenoss under the directory where your Zenoss product is installed.\n#\n#Custom Ubuntu Variables\nexport ZENHOME=/usr/local/zenoss\nexport RRDCACHED=/usr/local/zenoss/bin/rrdcached:g' /etc/init.d/zenoss"
update-rc.d zenoss defaults
chown root:zenoss /usr/local/zenoss/bin/nmap && chmod u+s /usr/local/zenoss/bin/nmap
chown root:zenoss /usr/local/zenoss/bin/zensocket && chmod u+s /usr/local/zenoss/bin/zensocket
chown root:zenoss /usr/local/zenoss/bin/pyraw && chmod u+s /usr/local/zenoss/bin/pyraw
echo 'watchdog True' >> /usr/local/zenoss/etc/zenwinperf.conf
TEXT1="     The Zenoss Install Script is Complete......browse to http://"
TEXT2=":8080"
IP=`ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
echo $TEXT1$IP$TEXT2

