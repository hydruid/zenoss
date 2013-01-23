#!/bin/bash

#####################################################
# Version: 01                                       #
# Status: Incomplete...under development            #
#                                                   #
# Zenoss Version: Core 4.2.3                        #
# OS: Ubuntu 12.10 x64                              #
######################################################

#Step-01: Determine OS and Arch
if grep -Fxq "Ubuntu 12.04.1 LTS" /etc/issue.net
    then
echo "Correct OS detected..."
    else
echo "Incorrect OS detected...stopping script"
exit 0
fi
if grep -FqR "Release amd64" /etc/apt/sources.list
    then
echo "Correct Arch detected...\n"
    else
echo "Incorrect Arch detected...stopping script"
        exit 0
fi
if whoami | grep zenoss
    then
echo "This script should not be ran as the zenoss user..."
        echo "You should run it as your normal admin user..."
        exit 0
    else
echo ""
fi
