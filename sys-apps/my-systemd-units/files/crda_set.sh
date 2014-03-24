#!/bin/bash
#CURRENT_COUNTRY=`iw reg get | grep -i country | cut -d ' ' -f 2 | cut -b 1-2`
#COUNTRY=`iw reg get | grep -i country | cut -d ' ' -f 2 | cut -b 1-2` /sbin/crda
COUNTRY=RU /usr/sbin/crda
