#!/bin/bash
/lib/dhcpcd/dhcpcd-run-hooks

case "$reason" in
	BOUND|BOUND6|REBIND|REBIND6|RENEW|RENEW6)
		/usr/local/sbin/fw_full.sh
		/etc/miniupnpd/iptables_init.sh
		/etc/miniupnpd/ip6tables_init.sh;;
esac
