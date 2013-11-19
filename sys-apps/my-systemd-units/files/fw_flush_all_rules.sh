#!/bin/sh
IPTABLES="/sbin/iptables"
IP6TABLES="/sbin/ip6tables"

for i in $IPTABLES $IP6TABLES; do
  $i --flush
  $i -t nat --flush
  $i -X

  $i -P INPUT ACCEPT
  $i -P OUTPUT ACCEPT
  $i -P FORWARD ACCEPT
done