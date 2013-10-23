#!/bin/bash

. ~zenoss/zenoss424-srpm_install/variables.sh

# Install Package Dependencies
apt-get install python-software-properties -y && sleep 1
if grep -Fxq "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" /etc/apt/sources.list
	then	echo "...PPA Repo already in sources list"
	else	echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list && echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
fi
apt-get update
if grep -Fxq "Debian GNU/Linux 7" /etc/issue.net
        then    apt-get install -f rrdtool libmysqlclient-dev nagios-plugins erlang subversion autoconf swig unzip zip g++ libssl-dev maven libmaven-compiler-plugin-java build-essential libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev oracle-java7-installer python-twisted python-gnutls python-twisted-web python-samba libsnmp-base bc rpm2cpio memcached libncurses5 libncurses5-dev libreadline6-dev libreadline6 librrd-dev python-setuptools python-dev erlang-nox smistrip -y
elif grep -Fxq "Debian GNU/Linux 6.0" /etc/issue.net
        then    apt-get install -f rrdtool libmysqlclient-dev nagios-plugins erlang subversion autoconf swig unzip zip g++ libssl-dev libmaven-compiler-plugin-java build-essential libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev oracle-java7-installer python-twisted python-gnutls python-twisted-web libsnmp-base bc rpm2cpio memcached libncurses5 libncurses5-dev libreadline6-dev libreadline6 librrd-dev python-setuptools python-dev erlang-nox smistrip -y
fi
