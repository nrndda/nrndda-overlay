#!/bin/bash
#BOUND|BOUND6|REBIND|REBIND6|RENEW|RENEW6)
case "$reason" in
	BOUND|BOUND6)
		/usr/local/sbin/fw_full.sh
		/etc/miniupnpd/iptables_init.sh
		/etc/miniupnpd/ip6tables_init.sh;;
esac

/lib/dhcpcd/dhcpcd-run-hooks
