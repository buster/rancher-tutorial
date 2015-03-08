#!/bin/bash

startup () {
echo "starting Nagios Agent"
/etc/init.d/nagios-nrpe-server start &>> /startlog
 }

shutdown () {
echo "shutting down"
/etc/init.d/nagios-nrpe-server stop &>> /startlog
exit
 }

trap shutdown SIGTERM SIGKILL

startup
while :			# This is the same as "while true".
do
        sleep 1	# This script is not really doing anything.
done
