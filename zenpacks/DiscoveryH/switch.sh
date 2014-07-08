#!/bin/bash
##########################################
# Version: 01h
#  Status: Functional
#   Notes: Still under development 
##########################################

# Notes
##Format: ./switch community host matrix

# Variables
SNMPVER="2c"
WALK="snmpwalk -v$SNMPVER -c$1 $2"
COM='sed -e 's/$/,/g''

# References
##First Match: grep -m 1 STRING
##Last Word: grep -o "[^ ]*$"
##Trim Quote: tr -d '"'
##Trim Space: tr -d ' '
##Print All After: grep -o "target_string.*"

# OEM
if [ $3 = "c1" ]; then			Q1="Cisco,"
	elif [ $3 = "c2" ]; then	Q1="Cisco,"
        elif [ $3 = "c3" ]; then        Q1="Cisco,"
	elif [ $3 = "d1" ]; then	Q1="Dell,"
fi
# Model 
if [ $3 = "c1" ]; then                  Q1+=$($WALK 1.3.6.1.2.1.47.1.1.1.1.13.1001 | grep -m 1 STRING | grep -o "[^ ]*$" | tr -d '"' | $COM)
        elif [ $3 = "c2" ]; then        Q1+=$($WALK 1.3.6.1.2.1.47.1.1.1.1.2.68420352 | grep -m 1 STRING | grep -o "[^ ]*$" | tr -d '"' | $COM)
        elif [ $3 = "c3" ]; then        Q1+=$($WALK 1.3.6.1.2.1.47.1.1.1.1.13.1|grep -m 1 STRING|tr -d ' '|grep -o ":.*"|tr -d '"'|tr -d ':'|$COM)
        elif [ $3 = "d1" ]; then        Q1+=$($WALK 1.3.6.1.2.1.47.1.1.1.1.13.2 | grep -m 1 STRING | grep -o "[^ ]*$" | tr -d '"' | $COM)
fi
# Serial Number 
if [ $3 = "c1" ]; then                  Q1+=$($WALK 1.3.6.1.2.1.47.1.1.1.1.11 | grep -m 1 STRING | grep -o "[^ ]*$" | tr -d '"' | $COM)
        elif [ $3 = "c2" ]; then        Q1+=$($WALK 1.3.6.1.2.1.47.1.1.1.1.11 | grep -m 1 STRING | grep -o "[^ ]*$" | tr -d '"' | $COM)
        elif [ $3 = "c3" ]; then        Q1+=$($WALK 1.3.6.1.2.1.47.1.1.1.1.11 | grep -m 1 STRING | grep -o "[^ ]*$" | tr -d '"' | $COM)
        elif [ $3 = "d1" ]; then        Q1+=$($WALK 1.3.6.1.2.1.47.1.1.1.1.11 | grep -m 1 STRING | grep -o "[^ ]*$" | tr -d '"' | $COM)
fi
# Site and Location 
if [ $3 = "c1" ]; then                  Q1+=$($WALK 1.3.6.1.2.1.1.6.0 | grep -m 1 STRING | grep -o '"[^"]\+"' |  tr -d '"' | $COM)
        elif [ $3 = "c2" ]; then        Q1+=$($WALK iso.3.6.1.2.1.1.6.0|grep -m 1 STRING|grep -o '"[^"]\+"'|awk '{print $1}'|tr -d '"'|$COM)
        elif [ $3 = "c3" ]; then        Q1+=$($WALK iso.3.6.1.2.1.1.6.0|grep -m 1 STRING|grep -o '"[^"]\+"'|awk '{print $1}'|tr -d '"'|$COM)
        elif [ $3 = "d1" ]; then        Q1+=$($WALK 1.3.6.1.2.1.1.6.0 | grep -m 1 STRING | grep -o '"[^"]\+"' |  tr -d '"' | $COM | $COM | $COM)
fi
# IP Address
if [ $3 = "c1" ]; then                  Q1+=$($WALK 1.3.6.1.2.1.4.20.1.1 | awk 'NF>1{print $NF}' | $COM)
        elif [ $3 = "c2" ]; then        Q1+=$($WALK 1.3.6.1.2.1.4.20.1.1 | awk 'NF>1{print $NF}' | $COM)
        elif [ $3 = "c3" ]; then        Q1+=$($WALK 1.3.6.1.2.1.4.20.1.1 | awk 'NF>1{print $NF}' | $COM)
        elif [ $3 = "d1" ]; then        Q1+=$($WALK 1.3.6.1.2.1.4.20.1.1 | awk 'NF>1{print $NF}' | awk '{print $0","}' | sed 's/,[ \t]\?/,/g')
fi
# Software Version
if [ $3 = "c1" ]; then                  Q1+=$($WALK 1.3.6.1.2.1.1.1.0 | grep -m 1 STRING | awk '{print $11}' | tr -d ',')
        elif [ $3 = "c2" ]; then        Q1+=$($WALK iso.3.6.1.2.1.47.1.1.1.1.10.67108992 | grep -m 1 STRING | awk '{print $4}' | tr -d '"')
	elif [ $3 = "c3" ]; then        Q1+=$($WALK 1.3.6.1.2.1.1.1.0 | grep -m 1 STRING | awk '{print $11}' | tr -d ',')
        elif [ $3 = "d1" ]; then        Q1+=$($WALK 1.3.6.1.2.1.1.1.0 | grep -m 1 STRING | awk '{print $6}' | tr -d ',')
fi

echo $Q1

exit 0

# Model Matrix
##c1 = cisco 3550, 3560
##c2 = cisco sb300
##c3 = cisco ap1140
##d1 = dell 3524/48, 6224/48
##s1 = sonicwall nsa 4500
