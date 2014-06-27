#!/bin/bash
##########################################
# Version: 01g
#  Status: Functional
#   Notes: Still under development 
##########################################

# Notes
##Format: ./switch community host matrix

# Variables
##SNMP
SNMPVER="2c"

# Query Order
##Make, Model, SN, Site, Location, IP Address, Version

# Model Matrix
##c1 = cisco 3550, 3560
##c2 = cisco sb300
##d1 = dell 3524/48, 6224/48
##s1 = sonicwall nsa 4500

# Cisco 1
if [ $3 = "c1" ]; then
        C1="Cisco" && C1+=","
        C1+=$(snmpwalk -v$SNMPVER -c$1 $2 1.3.6.1.2.1.47.1.1.1.1.13.1001 | grep -m 1 STRING | grep -o "[^ ]*$" | tr -d '"') && C1+=","
        C1+=$(snmpwalk -v$SNMPVER -c$1 $2 1.3.6.1.2.1.47.1.1.1.1.11 | grep -m 1 STRING | grep -o "[^ ]*$" | tr -d '"') && C1+=","
        C1+=$(snmpwalk -v$SNMPVER -c$1 $2 1.3.6.1.2.1.1.6.0 | grep -m 1 STRING | grep -o '"[^"]\+"' |  tr -d '"') && C1+=","
        C1+=$(snmpwalk -v$SNMPVER -c$1 $2 1.3.6.1.2.1.4.20.1.1 | awk 'NF>1{print $NF}') && C1+=","
        C1+=$(snmpwalk -v$SNMPVER -c$1 $2 1.3.6.1.2.1.1.1.0 | grep -m 1 STRING | awk '{print $11}' | tr -d ',')
	echo $C1
fi

# Cisco 2
if [ $3 = "c2" ]; then
        C2="Cisco" && C2+=","
        C2+=$(snmpwalk -v$SNMPVER -c$1 $2 iso.3.6.1.2.1.47.1.1.1.1.2.68420352 | grep -m 1 STRING | grep -o "[^ ]*$" | tr -d '"') && C2+=","
        C2+=$(snmpwalk -v$SNMPVER -c$1 $2 1.3.6.1.2.1.47.1.1.1.1.11 | grep -m 1 STRING | grep -o "[^ ]*$" | tr -d '"') && C2+=","
        C2+=$(snmpwalk -v$SNMPVER -c$1 $2 iso.3.6.1.2.1.1.6.0 | grep -m 1 STRING | grep -o '"[^"]\+"' | awk '{print $1}' | tr -d '"') && C2+=","
        C2+=$(snmpwalk -v$SNMPVER -c$1 $2 iso.3.6.1.2.1.1.6.0 | grep -m 1 STRING | grep -o '"[^"]\+"' | awk '{print $2}' | tr -d '"') && C2+=",,,"
        C2+=$(snmpwalk -v$SNMPVER -c$1 $2 1.3.6.1.2.1.4.20.1.1 | awk 'NF>1{print $NF}') && C2+=",,,,"
        C2+=$(snmpwalk -v$SNMPVER -c$1 $2 iso.3.6.1.2.1.47.1.1.1.1.10.67108992 | grep -m 1 STRING | awk '{print $4}' | tr -d '"')
        echo $C2
fi

# Dell 1
if [ $3 = "d1" ]; then
        D1="Dell" && D1+=","
        D1+=$(snmpwalk -v$SNMPVER -c$1 $2 1.3.6.1.2.1.47.1.1.1.1.13.2 | grep -m 1 STRING | grep -o "[^ ]*$" | tr -d '"') && D1+=","
        D1+=$(snmpwalk -v$SNMPVER -c$1 $2 1.3.6.1.2.1.47.1.1.1.1.11 | grep -m 1 STRING | grep -o "[^ ]*$" | tr -d '"') && D1+=","
        D1+=$(snmpwalk -v$SNMPVER -c$1 $2 1.3.6.1.2.1.1.6.0 | grep -m 1 STRING | grep -o '"[^"]\+"' |  tr -d '"') && D1+=","
        D1+=$(snmpwalk -v$SNMPVER -c$1 $2 1.3.6.1.2.1.4.20.1.1 | awk 'NF>1{print $NF}') && D1+=","
        D1+=$(snmpwalk -v$SNMPVER -c$1 $2 1.3.6.1.2.1.1.1.0 | grep -m 1 STRING | awk '{print $6}' | tr -d ',') && D1+=","
	echo $D1
fi

# Sonicwall 1
if [ $3 = "s1" ]; then
        echo "Sonicwall"
        snmpwalk -v$SNMPVER -c$1 $2 1.3.6.1.2.1.1.1.0 | awk '{print $5,$6}'
        #Unable to find OID for SN
        snmpwalk -v$SNMPVER -c$1 $2 1.3.6.1.2.1.1.6.0 | grep -m 1 STRING | grep -o '"[^"]\+"' |  tr -d '"'
        snmpwalk -v$SNMPVER -c$1 $2 1.3.6.1.2.1.4.20.1.1 | awk 'NF>1{print $NF}'
        snmpwalk -v$SNMPVER -c$1 $2 1.3.6.1.2.1.1.1.0 | grep -m 1 STRING | awk '{print $9}' | tr -d ')"'
fi

exit 0

# SNMP Config Examples
##Cisco
#snmp-server community pencil RO
#snmp-server location OKC Room#_IDF-#_RU#

##Dell
#snmp-server community pencil ro
#snmp-server location "OKC Room#_IDF-#_RU#"


