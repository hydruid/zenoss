#!/bin/bash
####################################################
#
# A simple script to auto-install Zenoss Core 4.2
#
# This script should be run on a base install of
# CentOS 5/6 or RHEL 5/6.
#
###################################################

umask 022
# this may or may not be helpful for an install issue some people are having, but shouldn't hurt:
unalias -a

if [ -L /opt/zenoss ]; then
	echo "/opt/zenoss appears to be a symlink. Please remove and re-run this script."
	exit 1
fi

if [ `rpm -qa | egrep -c -i "^mysql-"` -gt 0 ]; then
cat << EOF

It appears that the distro-supplied version of MySQL is at least partially installed.
Please remove these packages, as well as their dependencies (often postfix), and then
retry this script:

$(rpm -qa | egrep -i "^mysql-")

EOF
exit 1
fi

try() {
	"$@"
	if [ $? -ne 0 ]; then
		echo "Command failure: $@"
		exit 1
	fi
}

die() {
	echo $*
	exit 1
}

disable_repo() {
	local conf=/etc/yum.repos.d/$1.repo
	if [ ! -e "$conf" ]; then
		echo "Yum repo config $conf not found -- exiting."
		exit 1
	else
		sed -i -e 's/^enabled.*/enabled = 0/g' $conf
	fi
}

enable_service() {
	try /sbin/chkconfig $1 on
	try /sbin/service $1 start
}

#Now that RHEL6 RPMs are released, lets try to be smart and pick RPMs based on that
if [ -f /etc/redhat-release ]; then
	elv=`cat /etc/redhat-release | gawk 'BEGIN {FS="release "} {print $2}' | gawk 'BEGIN {FS="."} {print $1}'`
	#EnterpriseLinux Version String. Just a shortcut to be used later
	els=el$elv
else
	#Bail
	echo "Unable to determine version. I can't continue"
	exit 1
fi

# MySQL's official download RPM has different naming for RHEL 5...

if [ "$elv" = "5" ]; then
	myels="rhel5"
else
	myels="el$elv"
fi


echo "Ensuring Zenoss RPMs are not already present"
if [ `rpm -qa | grep -c -i ^zenoss` -gt 0 ]; then
	echo "I see Zenoss Packages already installed. I can't handle that"
	exit 1
fi

MYTMP="$(PATH=/sbin:/usr/sbin:/bin:/usr/bin mktemp -d)"
cd $MYTMP || die "Couldn't change to temporary directory"
#Disable SELinux:

echo "Disabling SELinux..."
if [ -e /selinux/enforce ]; then
	echo 0 > /selinux/enforce
fi

if [ -e /etc/selinux/config ]; then
	sed -i -e 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
fi

openjdk="$(rpm -qa | grep java.*openjdk)"
if [ -n "$openjdk" ]; then
	echo "Attempting to remove existing OpenJDK..."
	try rpm -e $openjdk
fi

# Defaults for user provided input
arch="x86_64"
# ftp mirror for MySQL to use for version auto-detection:
mysql_ftp_mirror="ftp://mirror.anl.gov/pub/mysql/Downloads/MySQL-5.5/"

# Auto-detect latest build:
build=4.2.0
zenoss_base_url="http://downloads.sourceforge.net/project/zenoss/zenoss-4.2/zenoss-$build"
zenpack_base_url="http://downloads.sourceforge.net/project/zenoss/zenpacks-4.2/zenpacks-$build"
zenoss_rpm_file="zenoss-$build.$els.$arch.rpm"
zenpack_rpm_file="zenoss-core-zenpacks-$build.$els.$arch.rpm"

# Let's grab Zenoss first...

zenoss_gpg_key="http://dev.zenoss.org/yum/RPM-GPG-KEY-zenoss"
for url in $zenoss_base_url/$zenoss_rpm_file $zenpack_base_url/$zenpack_rpm_file; do
	if [ ! -f "${url##*/}" ];then
		echo "Downloading ${url##*/}..."
		try wget -N $url
	fi
done

if [ `rpm -qa gpg-pubkey* | grep -c "aa5a1ad7-4829c08a"` -eq 0  ];then
	echo "Importing Zenoss GPG Key"
	try rpm --import $zenoss_gpg_key
fi

echo "Auto-detecting most recent MySQL Community release"
try rm -f .listing
try wget --no-remove-listing $mysql_ftp_mirror >/dev/null 2>&1
if [ -e .listing ]; then
	# note: .listing won't be created if you going thru a proxy server(e.g. squid)
	mysql_v=`cat .listing | awk '{ print $9 }' | grep MySQL-client | grep $myels.x86_64.rpm | sort | tail -n 1`
	# tweaks to isolate MySQL version:
	mysql_v="${mysql_v##MySQL-client-}"
	mysql_v="${mysql_v%%.$myels.*}"
	echo "Auto-detected version $mysql_v"
fi
if [ "${mysql_v:0:1}" != "5" ]; then
	mysql_v="5.5.27-1"
	echo "Auto-detect failure: $mysql_v - falling back to $mysql_v"
fi

jre_file="jre-6u31-linux-x64-rpm.bin"
jre_url="http://javadl.sun.com/webapps/download/AutoDL?BundleId=59622"
mysql_client_rpm="MySQL-client-$mysql_v.linux2.6.x86_64.rpm"
mysql_server_rpm="MySQL-server-$mysql_v.linux2.6.x86_64.rpm"
mysql_shared_rpm="MySQL-shared-$mysql_v.linux2.6.x86_64.rpm"
epel_rpm_url=http://dl.fedoraproject.org/pub/epel/$elv/$arch

echo "Installing EPEL Repo"
wget -r -l1 --no-parent -A 'epel*.rpm' $epel_rpm_url
try yum -y --nogpgcheck localinstall */pub/epel/$elv/$arch/epel-*.rpm
disable_repo epel

echo "Installing RabbitMQ"
try wget http://www.rabbitmq.com/releases/rabbitmq-server/v2.8.4/rabbitmq-server-2.8.4-1.noarch.rpm
try yum --enablerepo=epel -y --nogpgcheck localinstall rabbitmq-server-2.8.4-1.noarch.rpm
# Scientific Linux 6 includes AMQP daemon -> qpidd stop it before starting rabbitmq
if [ -e /etc/init.d/qpidd ]; then
       try /sbin/service qpidd stop
       try /sbin/chkconfig qpidd off
fi
enable_service rabbitmq-server

echo "Downloading Files"
if [ ! -f $jre_file ];then
	echo "Downloading Oracle JRE"
	try wget -N -O $jre_file $jre_url
	try chmod +x $jre_file
fi
echo "Installing JRE"
try ./$jre_file

echo "Downloading and installing MySQL RPMs"
#Only install if MySQL Is not already installed
for file in $mysql_client_rpm $mysql_server_rpm $mysql_shared_rpm;
do
	if [ ! -f $file ];then
		try wget -N http://cdn.mysql.com/Downloads/MySQL-5.5/$file
	fi
	if [ ! -f $file ];then
		echo "Failed to download $file. I can't continue"
		exit 1
	fi
	try yum -y --nogpgcheck localinstall $file
done

echo "Installing optimal /etc/my.cnf settings"
cat >> /etc/my.cnf << EOF
[mysqld]
max_allowed_packet=16M
innodb_buffer_pool_size = 256M
innodb_additional_mem_pool_size = 20M
EOF

echo "Configuring MySQL"
enable_service mysql
/usr/bin/mysqladmin -u root password ''
/usr/bin/mysqladmin -u root -h localhost password ''

# set up rrdtool, etc.

echo "Enabling rpmforge repo..."
try wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.2-2.$els.rf.$arch.rpm
try yum --nogpgcheck -y localinstall rpmforge-release-0.5.2-2.$els.rf.$arch.rpm
disable_repo rpmforge
	
echo "Installing rrdtool"
try yum -y --enablerepo='rpmforge*' install rrdtool-1.4.7

echo "Installing Zenoss"
try yum -y localinstall --enablerepo=epel $zenoss_rpm_file
echo "Configuring and Starting some Base Services"
for service in memcached snmpd zenoss; do
	try /sbin/chkconfig $service on
	try /sbin/service $service start
done

echo "Installing Core ZenPacks - this takes several minutes..."
try yum -y localinstall $zenpack_rpm_file

cat << EOF
Zenoss Core $build install completed successfully!

Please visit http://127.0.0.1:8080 in your favorite Web browser to complete
setup.

NOTE: You may need to disable or modify this server's firewall to access port
8080. To disable this system's firewall, type:

# service iptables save
# service iptables stop
# chkconfig iptables off

Alternatively, you can modify your firewall to enable incoming connections to
port 8080. Here is a full list of all the ports Zenoss accepts incoming
connections from, and their purpose:

	8080 (TCP)                 Web user interface
	11211 (TCP and UDP)        memcached
	514 (UDP)                  syslog
	162 (UDP)                  SNMP traps


If you encounter problems with this script, please report them on the
following wiki page:

http://wiki.zenoss.org/index.php?title=Talk:Install_Zenoss

Thank you for using Zenoss. Happy monitoring!
EOF
