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
apt-get install rrdtool mysql-server mysql-client mysql-common libmysqlclient-dev rabbitmq-server nagios-plugins erlang subversion autoconf swig unzip zip g++ libssl-dev maven libmaven-compiler-plugin-java build-essential libreadline-dev libsnmp-dev zip libssl0.9.8 libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev libsmi2-common python-twisted python-gnutls python-twisted-web python-samba

#. ref: http://d.hatena.ne.jp/minghai/20120503/p1
function get_jdk(){
    # second and nano second
    T=$(date +%s%N)
    # Make it 13 digits cause JavaScript Date has only millisecond
    T=${T:0:13}
    P1="s_nr=${T};"
    P2="gpw_e24=http%3A%2F%2Fwww.oracle.com%2Ftechnetwork%2Fjava%2Fjavase%2Fdownloads%2Fjdk6-downloads-1637591.html;"
    P3="s_sq=%5B%5BB%5D%5D"
    COOKIE="$P1 $P2 $P3"
    AGENT='Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1.16) Gecko/20120421 Firefox/11.0'
    TARGET='http://download.oracle.com/otn-pub/java/jdk/6u34-b04/jdk-6u34-linux-x64.bin'
    REFERER='http://www.oracle.com/technetwork/java/javase/downloads/jdk6-downloads-1637591.html'
    curl -k -b "$COOKIE" --user-agent "$AGENT" --referer "$REFERER" -L -O "$TARGET"
}

echo "Install Oracle JDK1.6_34u"
if [ -f /usr/lib/jvm/jdk1.6.0_34/COPYRIGHT ];
    then
        echo "Oracle JDK1.6_34u Already Installed.....Skipping"
    else
        ATTEMPT=3
        FAILED=0
        ROUND=0
        while [[ ! -f ./jdk-6u34-linux-x64.bin ]]; do
            ROUND=$(($ROUND+1))
            echo "Trying to download Oracle JDK1.6_34u ($ROUND/$ATTEMPT)"
            get_jdk
            if [[ ! -f ./jdk-6u34-linux-x64.bin  ]]; then
                FAILED=$(($FAILED+1))
                if [[ "$FAILED" -eq "$ATTEMPT" ]]; then
                    echo ""
                    echo ""
                    echo "#######Error:#######"
                    echo "Oracle JDK1.6_u34 .bin not found "
                    echo "Please manually download jdk-6u34-linux-x64.bin from the below link"
                    echo "http://www.oracle.com/technetwork/java/javasebusiness/downloads/java-archive-downloads-javase6-419409.html#jdk-6u34-oth-JPR "
                    echo "Save it in the same directory as install.sh"
                    exit
                fi
            else
                echo "Oracle JDK1.6_u34 .bin found"
                chmod u+x jdk-6u34-linux-x64.bin
                ./jdk-6u34-linux-x64.bin
                rm -fr /usr/lib/jvm
                mkdir /usr/lib/jvm/
                mv jdk1.6.0_34 /usr/lib/jvm/
                break
            fi
        done
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
echo "Setting Socket buffers"
echo 'net.core.rmem_default=1048576
net.core.rmem_max=1048576
net.core.wmem_default=1048576
net.core.wmem_max=1048576' >> /etc/sysctl.conf
sysctl -w net.core.rmem_default=1048576
sysctl -w net.core.rmem_max=1048576
sysctl -w net.core.wmem_default=1048576
sysctl -w net.core.wmem_max=1048576

echo "Zenoss Installation Preparation (may take a few minutes)"
sudo svn --quiet co http://dev.zenoss.org/svn/tags/zenoss-4.2.0/inst /home/zenoss/zenoss-inst
sudo chown -R zenoss:zenoss /home/zenoss/zenoss-inst
echo "###############################################"
echo "##    Ready for install!!"
echo "##    Follow the Instructions below"
echo "##"
echo "##    sudo su zenoss"
echo "##    cd /home/zenoss/zenoss-inst"
echo "##    ./install.sh"
echo "##"
echo "##    Zenoss Post Installation Adjustments"
echo "##    1. setuid to open raw sockets"
echo "##    export ZENHOME=/usr/local/zenoss"
echo "##    chown root:zenoss \$ZENHOME/bin/{zensocket,pyraw,nmap}"
echo "##    chmod 04750 \$ZENHOME/bin/{zensocket,pyraw,nmap}"
echo "##    2. ..."
echo "##  "
echo "###############################################"

