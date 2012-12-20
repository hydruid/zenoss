#!/bin/bash
###########################################################
#
# A simple script to auto-install Zenoss Core 4.2.0
#
# This script should be run on a base install of
# Ubuntu 12.04 x64
#
# Status: Functional.....needs automation
# Version: 06-a
#
###########################################################

echo "Install Dependencies"
apt-get install rrdtool mysql-server mysql-client mysql-common libmysqlclient-dev rabbitmq-server nagios-plugins erlang subversion autoconf swig unzip zip g++ libssl-dev maven libmaven-compiler-plugin-java build-essential libreadline-dev libsnmp-dev zip libssl0.9.8 libxml2-dev libxslt-dev libldap2-dev libsasl2-dev snmp-mibs-downloader python-twisted python-gnutls python-twisted-web python-samba

echo "Install Oracle JDK1.6_34u"
if [ -f /usr/lib/jvm/jdk1.6.0_34/COPYRIGHT ];
        then
                echo "Oracle JDK1.6_34u Already Installed.....Skipping"
        else
        if [ -f jdk-6u34-linux-x64.bin ];
                then
                        echo "Oracle JDK1.6_u34 .bin found"
                        chmod u+x jdk-6u34-linux-x64.bin
                        ./jdk-6u34-linux-x64.bin
                        rm -fr /usr/lib/jvm
                        mkdir /usr/lib/jvm/
                        mv jdk1.6.0_34 /usr/lib/jvm/
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

echo "Zenoss User Adjustments"
if [ -f /home/zenoss/.bashrc ];
        then
                echo "Zenoss User already exists.....Skipping"
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
echo "Applying MySQL Adjustments"
echo '#This is commented out as it is the default parameter' >> /etc/mysql/my.cnf
echo '#max_allowed_packet=16M' >> /etc/mysql/my.cnf
echo 'innodb_buffer_pool_size=256M' >> /etc/mysql/my.cnf
echo 'innodb_additional_mem_pool_size=20M' >> /etc/mysql/my.cnf
echo "Applying SNMP Adjustments"
sed -i 's/mibs/#mibs/g' /etc/snmp/snmp.conf
echo "Applying Java Adjustments"
update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk1.6.0_34/bin/javac 1
update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk1.6.0_34/bin/java 1

echo "Zenoss Installation Preparation (may take a few minutes)"
sudo svn --quiet co http://dev.zenoss.org/svn/tags/zenoss-4.2.0/inst /home/zenoss/zenoss-inst
sudo chown -R zenoss:zenoss /home/zenoss/zenoss-inst
echo "###############################################"
echo "##        Ready for install!!"
echo "##        Follow the Instructions below"
echo "##"
echo "##        sudo su zenoss"
echo "##        cd /home/zenoss/zenoss-inst"
echo "##        ./install.sh"
echo "##"
echo "##        Zenoss Post Installation Adjustments"
echo "##        Nmap setuid fix"
echo "##        sudo chown root:zenoss /usr/local/zenoss/bin/nmap && sudo chmod u+s /usr/local/zenoss/bin/nmap"
echo "###############################################"

