#!/bin/bash
#######################################################
# Version: 01a Alpha02                                       
#######################################################

# Script Variables
ZENHOME="/usr/local/zenoss"
PYTHONPATH="/usr/local/zenoss/lib/python"
PATH="/usr/local/zenoss/bin:$PATH"
INSTANCE_HOME="$ZENHOME"

# Functions
def detectos(fname, txt):
    with open(fname) as dataf:
        return any(txt in line for line in dataf)
