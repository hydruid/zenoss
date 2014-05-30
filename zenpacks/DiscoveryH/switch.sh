#!/bin/bash
##########################################
# Version: 01a Alpha01
#  Status: Not Functional
#   Notes: Under Constructions
##########################################

# Variables
SNMPVER="2c"
SNMPCOM="cnc-ro"

# Queries
snmpwalk -v$SNMPVER -c$SNMPCOM $1 1.3.6.1.2.1.47.1.1.1.1.11 | grep -m 1 STRING | grep -o "[^ ]*$" | tr -d '"'

exit 0
