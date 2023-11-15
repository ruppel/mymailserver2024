#!/bin/bash

# --------------------
# Configuration start
# --------------------

# findtime in seconds
# similar to the findtime in fail2ban
findtime=$((5*24*60*60)) # days*hours*minutes*seconds

# exclude jails
# Use jailnames separated with <space> to be excluded from watching
excluded_jails="recidive recidive-subnet"

# max ips
# maximum number of different ips that are allowed
maxips=3

# logfilename
# The filename of the fail2ban log file
# (shouldn't be changed very often...)
logfilename=/var/log/fail2ban.log

# outputfilename
# file where to log the found subnets
# should correspond to the parameter "logpath" in the [recidive-subnet] jail definition in jail.local
outputfile=/var/log/fail2ban-subnet.log

# path to awk script
# Where did you store the awk script?
awkscript={{ fail2ban.fail2ban_subnet_folder }}fail2ban-subnet.awk

# --------------------
# Configuration end!
# --------------------

if [ -f $outputfile ]
  then
    last=`tail -1 $outputfile | cut -f3 -d' '`
  else
    last=$((`date +%s`-$findtime))
fi

# #TODO perhaps there is an easy way to also include the *.gz files from logrotate
nextolderlogfilename=$logfilename.1

if [ -f $nextolderlogfilename ]
  then
    filestoread="$nextolderlogfilename $logfilename"
  else
    filestoread=$logfilename
fi

awk -f $awkscript -v findtime=$findtime -v excluded_jails="$excluded_jails" -v maxips=$maxips -vlast=$last $filestoread >> $outputfile
