#!/bin/bash
smbd_qty=$(/bin/ps axu | /bin/grep smbd | /usr/bin/wc -l)
smbd_thsd=350
if [ "$smbd_qty" -gt "$smbd_thsd" ]; then
        logfile="/root/samba_watchdog.log"
        echo "$(/bin/date '+%Y-%m-%d %H:%M') $smbd_qty smbd processes detected (above $smbd_thsd threshold); stopping Samba" >> $logfile
        /sbin/service smb stop && /bin/sleep 10
        while [ $(/bin/ps axu | /bin/grep smbd | /usr/bin/wc -l) -gt 2 ]; do
                /usr/bin/killall smbd
        done
        echo "$(/bin/date '+%Y-%m-%d %H:%M') starting over smbd, then renice them to 10" >> $logfile
        /sbin/service smb start && /bin/sleep 10
        for p in $(/bin/ps -C smbd | /bin/cut -c -5); do
                /usr/bin/renice -n 10 $p
        done
        echo "$(/bin/date '+%Y-%m-%d %H:%M') there are now $(/bin/ps axu | /bin/grep smbd | /usr/bin/wc -l) smbd processes" >> $logfile
fi
