#!/bin/sh
case "$reason" in
        BOUND|BOUND6|REBIND|REBIND6|RENEW|RENEW6|REBOOT|REBOOT6|INFORM|INFORM6)
                /usr/local/sbin/fw_full.sh
                /etc/miniupnpd/iptables_init.sh
                /etc/miniupnpd/ip6tables_init.sh
	;;
esac

