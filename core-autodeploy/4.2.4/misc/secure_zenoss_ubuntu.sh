#!/bin/bash
#######################################################
# Version: 01a                                        #
#   Notes: This is a modified copy of the official    #
#          'secure_zenoss.sh' that works with Ubuntu  #
#######################################################

###############################################################################
#
# A script to secure a standalone Zenoss installation.
#
# This script should be run after installing Zenoss, but before starting the
# zenoss service for the first time.
#
# Example steps:
#
#     yum -y --nogpgcheck --enablerepo=epel localinstall zenoss_core-4.2.3-1697.el6.x86_64.rpm
#     su - zenoss
#     sh secure_zenoss.sh
#     exit
#     service zenoss start
#
#Custom Ubuntu Variables
. /home/zenoss/zenoss424-srpm_install/variables.sh
#
###############################################################################

cat << END_OF_CHANGELOG > /dev/null

2013-01-06  Daniel Robbins <drobbins@zenoss.com>

    * Make etc/ perm fix always enabled (wouldn't enable properly on some builds)

2013-01-04  Chet Luther  <cluther@zenoss.com>

    * Initial revision
    * ZEN-4836: Set 0600 permission on all configuration files
    * ZEN-4837: Use a randomized secure password everywhere
    * ZEN-????: Zenoss install should help secure MySQL root user
    * ZEN-1847: Restrict zeneventserver to only listen on 127.0.0.1

END_OF_CHANGELOG


### Prerequisites #############################################################

if [ -z "$ZENHOME" ]
then
    echo "ZENHOME not set. Login as the zenoss user before running this script."
    exit 1
fi

if ! openssl --version >/dev/null 2>&1
then
    echo "This script requires the openssl command line tool to be installed."
    exit 2
fi

### ZEN-4837: Set 0600 permission on all configuration files (ZEN-4836) #######

echo "Restricting permissions on $ZENHOME/etc/*.conf*"
chmod 0600 $ZENHOME/etc/*.conf*

### ZEN-4837: Use a randomized secure password everywhere #####################

# Generate a random secure password. Must replace / to make later sed simpler.
RANDOM_PASSWORD=$(openssl rand -base64 15 | sed 's/\//x/')

# Ensure that global.conf exists. Otherwise zenglobalconf fails.
if [ ! -f $ZENHOME/etc/global.conf ]
then
    cp $ZENHOME/etc/global.conf.example $ZENHOME/etc/global.conf
fi

# Update global.conf passwords only if they haven't already been set.
GLOBAL_CONF_PWD_PROPERTIES="
zodb-password
amqppassword
zep-password
hubpassword
"

for PWD_PROP in $GLOBAL_CONF_PWD_PROPERTIES
do
    # To set properties that don't exist (i.e. hubpassword)
    if ! zenglobalconf -p $PWD_PROP > /dev/null
    then
        echo "Assigning secure password for global.conf:$PWD_PROP"
        zenglobalconf -u $PWD_PROP=$RANDOM_PASSWORD
        echo "Assigning secure password for global.conf:$PWD_PROP"
        zenglobalconf -u $PWD_PROP=$RANDOM_PASSWORD
    fi
done

# Get the current secure password in case we didn't set it on this run.
RANDOM_PASSWORD=$(zenglobalconf -p hubpassword)

# Update hubpasswd only if it hasn't been changed from the default.
if ! grep -q "^admin:${RANDOM_PASSWORD}\$" $ZENHOME/etc/hubpasswd
then
    echo "Assigning secure password for hubpassword:admin"
    sed -i "s/admin:.*/admin:${RANDOM_PASSWORD}/" $ZENHOME/etc/hubpasswd
fi


### ZEN-????: Zenoss install should help secure MySQL root user ###############

MYSQL_ADMIN_PASSWORD=$(zenglobalconf -p zodb-admin-password)
if [ -z "$(zenglobalconf -p zodb-admin-password)" ]
then
    if mysql -uroot mysql -e "select 1" >/dev/null 2>&1
    then
        echo "MySQL is configured with a blank root password."

            printf "Configure a secure MySQL root password? [Yn]: "
            read YESNO

            if echo "$YESNO" | egrep -iq Y
            then
                while [ 1 ]
                do
                    printf "  Enter new MySQL root password: "
                    stty -echo ; read MYSQL_ROOT_PASSWORD_1 ; stty echo
                    echo

                    printf "Confirm new MySQL root password: "
                    stty -echo ; read MYSQL_ROOT_PASSWORD_2 ; stty echo
                    echo

                    if [ -z "$MYSQL_ROOT_PASSWORD_1" ]
                    then
                        echo "A blank password is not acceptable."
                        continue
                    fi

                    if [ "$MYSQL_ROOT_PASSWORD_1" != "$MYSQL_ROOT_PASSWORD_2" ]
                    then
                        echo "Passwords don't match. Try again."
                        continue
                    fi

                    break
                done

                echo "Changing MySQL root password."
                mysqladmin -uroot -h localhost password "$MYSQL_ROOT_PASSWORD_1"

                for ROOT_PWD_PROP in zodb-admin-password zep-admin-password
                do
                    echo "Assigning MySQL root password for global.conf:$ROOT_PWD_PROP"
                    zenglobalconf -u $ROOT_PWD_PROP="$MYSQL_ROOT_PASSWORD_1"
                done
           
        fi

    # Using a blank MySQL root password failed.
    else
        echo "Zenoss needs root MySQL access to create its databases."

        if [ -t 1 ]
        then
            printf "Enter the MySQL root user password: "
            stty -echo ; read MYSQL_ROOT_PASSWORD ; stty echo
            echo

            for ROOT_PWD_PROP in zodb-admin-password zep-admin-password
            do
                echo "Assigning MySQL root password for global.conf:$ROOT_PWD_PROP"
                zenglobalconf -u $ROOT_PWD_PROP="$MYSQL_ROOT_PASSWORD"
            done
        fi
    fi
fi


### ZEN-1847: Restrict zeneventserver to only listen on 127.0.0.1 #############

if ! grep -q 'Djetty.host=localhost' ~/.bashrc
then
    echo "Forcing zeneventserver to only listen on 127.0.0.1:8084"
    echo 'export DEFAULT_ZEP_JVM_ARGS="-Djetty.host=localhost -server"' >> ~/.bashrc
fi
