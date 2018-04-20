#!/bin/bash

# Description: Monitor disk usage health for remote systems

# In this log file the info about du for remote hosts is written: a var is used for reference to work with it:
logfile="diskusage.log"

# if there is an argument (calling script with filename as argument), then logfile is that filename passed by:
if [[ -n $1 ]]
then
	logfile=$1
fi

# if the logfile does not exist, it is created
if [ ! -e $logfile ]
then
	printf "%-28s %-24s %-9s %-8s %-6s %-6s %-6s %s\n" "Date" "IP address" "Device" "Capacity" "Used" "Free" "Percent" "Status" > $logfile
fi

# IP_LIST=$(fping -a 10.57.122.0/24 -g 2>/dev/null)
IP_LIST="192.168.0.240"

(
for ip in $IP_LIST
do
	# ssh (with auto-login using keys) to execute remotely command dh -H in each host from the IP_LIST, one by one in the for loop: (a user must have auto-login)
	#ssh natasa@${ip} 'df -H' | grep '^/dev/' | sort -nrk 1 > /tmp/remote_hosts_$$.df

	# in my local machine:
	df -H | egrep '^/dev/|^/home/' | sort -nrk 1 > /tmp/remote_hosts_$$.df

	while read line; # read line from file specified in last line, done
	do
		cur_date=$(date +%D)
		printf "%-8s %-14s " $cur_date $ip

		echo $line | awk '{ printf("%-29s %-8s %-6s %-6s %-8s",$1,$2,$3,$4,$5); }'

		pusg=$(echo $line | egrep -o "[0-9]+%" | tr -d '%') # get only numbers, wildcard is number plus %
		case $pusg in
			[0-6]* | ?)
				echo "Safe disk, plenty of space"
				;;
			[7-8]?)
				echo "Probably you might want to think about cleaning out"
				;;
			9[0-8])
				echo "You better check this disk ASAP"
				;;
			99)
				echo "Disk is drowning, running out of space"
				;;
			*)	echo "Not enough information"
				;;
		esac
	done< /tmp/remote_hosts_$$.df
done
) >> $logfile