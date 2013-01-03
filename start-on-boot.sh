#!/bin/bash
cp /usr/local/zenoss/zenoss /etc/init.d
update-rc.d -f /etc/init.d/zenoss start 99 2 3 4 5 .
update-rc.d -f /etc/init.d/zenoss reboot 90 0 6 .
update-rc.d zenoss start 99 2 3 4 5 . stop 90 0 6 .
