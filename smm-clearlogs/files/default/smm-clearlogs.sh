#!/bin/bash

export GZLOGS=`find /var/log -name "*.gz"`
export ROTLOGS=`find /var/log -name "*\.[0-9]"`
export DATELOGS=`find /var/log -name "*\.2012*"`

if [ `df -h|grep /var|awk '{print $5}'|cut -c1-2` -gt 89 ]
	then

		for GZLOG in $GZLOGS; do
			rm -f $GZLOG
		done

		for ROTLOG in $ROTLOGS; do
			rm -f $ROTLOG
		done

		for DATELOG in $DATELOGS; do
			rm -f $DATELOG
		done

		service gdma restart
		
	else

		echo Disk not full enough yet.

fi