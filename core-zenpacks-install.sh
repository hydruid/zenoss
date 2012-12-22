#!/bin/bash
###########################################################
#
# A simple script to auto-install Zenoss Core 4.2 ZenPacks
#
# This script should be run on a base install of
# Ubuntu 12.04 x64
#
# Status: Functional....still needs work
# Version: 01-Beta04
#
###########################################################

export ZENHOME=/usr/local/zenoss
export PYTHONPATH=/usr/local/zenoss/lib/python
export PATH=/usr/local/zenoss/bin:$PATH
export INSTANCE_HOME=$ZENHOME
export ZENPATH=/usr/local/zenoss/bin
export RRDCACHED=$ZENPATH/rrdcached
EGG_URL='http://zenpacks.zenoss.com/pypi/eggs/none'
EGG_PREFIX='ZenPacks.zenoss'
EGGS='ApacheMonitor-2.1.3-py2.7.egg DellMonitor-2.2.0-py2.7.egg DigMonitor-1.0.3-py2.7.egg DnsMonitor-2.0.3-py2.7.egg FtpMonitor-1.0.3-py2.7.egg HPMonitor-2.1.0-py2.7.egg HttpMonitor-2.0.5-py2.7.egg IRCDMonitor-1.0.3-py2.7.egg JabberMonitor-1.0.3-py2.7.egg LDAPMonitor-1.3.0-py2.7.egg MySqlMonitor-2.2.0-py2.7.egg NNTPMonitor-1.0.3-py2.7.egg NtpMonitor-2.0.4-py2.7.egg RPCMonitor-1.0.3-py2.7.egg ZenJMX-3.8.0-py2.7.egg LinuxMonitor-1.2.0-py2.7.egg ZenAWS-1.0.7-py2.7.egg ZenossVirtualHostMonitor-2.4.0-py2.7.egg EsxTop-1.0.3-py2.7.egg XenMonitor-1.1.0-py2.7.egg DeviceSearch-1.2.0-py2.7.egg PySamba-1.0.0-py2.7-linux-x86_64.egg WindowsMonitor-1.0.2-py2.7.egg ActiveDirectory-2.1.0-py2.7.egg IISMonitor-2.0.2-py2.7.egg MSExchange-2.0.4-py2.7.egg MSMQMonitor-1.2.1-py2.7.egg MSSQLServer-2.0.3-py2.7.egg'

function check_eggs(){
    echo "Checking eggs ..." 
    if [[ ! -d ./eggs ]]; then
        echo "Eggs not found, download now ..."
        mkdir -p ./eggs
    fi
    cd ./eggs
    for egg in $EGGS; do
        if [[ ! -f $EGG_PREFIX.$egg ]]; then
            echo "Downloading missing egg $egg ..."
            wget $EGG_URL/$EGG_PREFIX.$egg --quiet
        fi
    done
    cd ../
}

function get_eggs(){
    echo "Force download ..."
    rm -rf ./eggs
    mkdir -p ./eggs
    cd ./eggs
    for egg in $EGGS; do
        echo "Downloading $EGG_PREFIX.$egg ..."
        wget $EGG_URL/$EGG_PREFIX.$egg --quiet
    done
    cd ../
}

function eat_eggs(){
    cd ./eggs
    for egg in $EGGS; do
        sudo -u zenoss -H -E $ZENPATH/zenpack --install $EGG_PREFIX.$egg
    done
    cd ../
}

function fix_missing_lib(){
    sudo -u zenoss wget http://hydruid-blog.com/wp-content/uploads/2012/12/pysamba.zip
    sudo -u zenoss mv pysamba.zip /usr/local/zenoss/ZenPacks/ZenPacks.zenoss.PySamba-1.0.0-py2.7-linux-x86_64.egg/ZenPacks/zenoss/PySamba/lib/
    cd /usr/local/zenoss/ZenPacks/ZenPacks.zenoss.PySamba-1.0.0-py2.7-linux-x86_64.egg/ZenPacks/zenoss/PySamba/lib/
    sudo -u zenoss unzip pysamba.zip
    sudo -u zenoss rm pysamba.zip
    sudo -u zenoss cp pysamba/easy-install.pth /usr/local/zenoss/ZenPacks/
}

function fix_config(){
    sudo -u zenoss touch /usr/local/zenoss/etc/zenjmx.conf
    sudo -u zenoss touch /usr/local/zenoss/etc/zenwinperf.conf
}


function main(){
    echo "Zenpack Core"
    echo "#Zenpacks Source: http://zenpacks.zenoss.com/pypi/none/4.2/ "
    eat_eggs
    fix_missing_lib
    fix_config
    echo "Restart your server"
}

case $1 in
    auto)
        check_eggs
        main
        ;;
    force-download)
        get_eggs
        main
        ;;
    *)
        echo "USEAGE:$0 {auto|force_download)}"
        ;;
esac
