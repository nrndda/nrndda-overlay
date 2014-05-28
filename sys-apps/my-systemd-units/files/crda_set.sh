#!/bin/bash
#CURRENT_COUNTRY=`iw reg get | grep -i country | cut -d ' ' -f 2 | cut -b 1-2`
#COUNTRY=`iw reg get | grep -i country | cut -d ' ' -f 2 | cut -b 1-2` /sbin/crda
#It MUST be 00 code. After that it'll swich to needed country code.
COUNTRY=00 /usr/sbin/crda 2>/dev/null
