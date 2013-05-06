#!/bin/bash
#
# Version: 02
# Notes: This scripts help to ensure that Zenoss starts automatically after a reboot.
#

if [ -f /usr/local/zenoss/var/zenhub-localhost.pid ];
        then
                echo "Zenoss is running"
        else
                echo "Zenoss not running"
                /usr/local/zenoss/bin/zenoss restart
fi

if [ -f /usr/local/zenoss/var/zenwinperf-localhost.pid ];
        then
                echo "ZenWinPerf is running"
        else
                echo "ZenWinPerf not running"
                /usr/local/zenoss/bin/zenwinperf restart
fi

exit 0
