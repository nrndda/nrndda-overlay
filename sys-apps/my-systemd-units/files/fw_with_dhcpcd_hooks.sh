#!/bin/bash
/lib/dhcpcd/dhcpcd-run-hooks

case "$reason" in
BOUND|BOUND6|REBIND|REBIND6|RENEW|RENEW6)
/usr/local/sbin/fw_full.sh
;;
esac


