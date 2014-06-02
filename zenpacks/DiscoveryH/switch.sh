#!/bin/bash
##########################################
# Version: 01a Alpha02
#  Status: Functional but not for Production
#   Notes: Under Construction
##########################################

# Variables
## SNMP
SNMPVER="2c"

# Cisco Query
if [ $3 = "c" ]; then
        echo "Cisco"
	snmpwalk -v$SNMPVER -c$1 $2 1.3.6.1.2.1.47.1.1.1.1.11 | grep -m 1 STRING | grep -o "[^ ]*$" | tr -d '"'
        snmpwalk -v$SNMPVER -c$1 $2 1.3.6.1.2.1.47.1.1.1.1.13.1001 | grep -m 1 STRING | grep -o "[^ ]*$" | tr -d '"'
        snmpwalk -v$SNMPVER -c$1 $2 1.3.6.1.2.1.1.6.0 | grep -m 1 STRING | grep -o '"[^"]\+"' |  tr -d '"'
        snmpwalk -v$SNMPVER -c$1 $2 1.3.6.1.2.1.4.20.1.1 | awk 'NF>1{print $NF}'
        snmpwalk -v$SNMPVER -c$1 $2 1.3.6.1.2.1.1.1.0 | grep -m 1 STRING | awk '{print $11}' | tr -d ','
fi

# Dell Query
if [ $3 = "d" ]; then
        echo "Dell"
        snmpwalk -v$SNMPVER -c$1 $2 1.3.6.1.2.1.47.1.1.1.1.11 | grep -m 1 STRING | grep -o "[^ ]*$" | tr -d '"'
        snmpwalk -v$SNMPVER -c$1 $2 1.3.6.1.2.1.47.1.1.1.1.13.2 | grep -m 1 STRING | grep -o "[^ ]*$" | tr -d '"'
fi


exit 0

