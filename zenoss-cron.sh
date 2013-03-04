#!/bin/bash

#################
# Version: 01   #
#################

if [ -f /usr/local/zenoss/var/zenhub-localhost.pid ];
        then
                echo "Zenoss is running"
        else
                echo "Zenoss not running"
  	/usr/local/zenoss/bin/zenoss restart
fi

exit 0
