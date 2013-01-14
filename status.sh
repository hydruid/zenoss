#####################################################
#!/bin/bash                                          #
#                                                    #
# Version: 02                                        #
# Status: Working...needs further testing            #
#                                                    #
######################################################

if [ -f /usr/local/zenoss/var/zenhub-localhost.pid ];
        then
                echo "Do nothing, Zenhub already running"
        else
                echo "Restart Zenoss, Zenhub not running"
                /usr/local/zenoss/bin/zenoss restart
fi

exit 0
