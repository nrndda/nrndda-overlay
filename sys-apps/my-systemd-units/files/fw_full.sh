#!/bin/sh
IPTABLES="/sbin/iptables"
IP6TABLES="/sbin/ip6tables"
IFCONFIG='/bin/ifconfig'

function flush()
{
  for i in $IPTABLES $IP6TABLES; do
    $i --flush
    $i -t nat --flush
    $i -X

    $i -P INPUT ACCEPT
    $i -P OUTPUT ACCEPT
    $i -P FORWARD ACCEPT
  done
}
######################################################################
#####
#
# 1. Configuration options.
#
GLOBAL_BROADCAST="255.255.255.255"
IPv6_LINK_LOCAL="fe80::/10"

# 1.1 Internal Local Area Network configuration.
LAN_IFACE_INT="br0"
LAN_IP_INT="10.0.0.1"
LAN_IPv6_INT="fe80::62eb:69ff:fe09:f7c2"
LAN_IPv6_INT_ALL="fe80::62eb:69ff:fe09:f7c2 fe80::4e0f:6eff:fe0d:4995"
LAN_NETMASK_INT="255.255.255.0"
LAN_BROADCAST_INT="10.0.0.255"
LAN_IP_RANGE_INT="$LAN_IP_INT/$LAN_NETMASK_INT"
IFACES_IN_BRIDGE="enp3s0 wlp9s0"

#
# 1.2 External Local Area Network configuration.
LAN_IFACE_EXT="enp0s18f2u1"

#
# 1.3 Internet Configuration.
INET_IFACE="ppp0"
if $IFCONFIG | grep -q $INET_IFACE; then
  WITH_INET="true";
else
  WITH_INET="false";
fi

#
# 1.4 VPN Configuration.
VPN_IFACE="tun0"
if $IFCONFIG | grep -q $VPN_IFACE; then
  WITH_VPN="true";
else
  WITH_VPN="false";
fi

#
# 1.5 Localhost Configuration.
LO_IFACE="lo"
LO_IP="127.0.0.1"
LO_IPv6="::1"

######################################################################
flush
# Once tables wasn't flushed by one exec of this command.
# Run it twice just to be sure.
flush
######################################################################
#
# 3. /proc set up.
#
#
# 3.1 Required proc configuration
echo "1" > /proc/sys/net/ipv4/ip_forward
echo "1" > /proc/sys/net/ipv6/conf/all/forwarding
echo "1" > /proc/sys/net/ipv6/conf/default/forwarding

echo "2" > /proc/sys/net/ipv6/conf/$LAN_IFACE_EXT/accept_ra
if $WITH_INET; then
  echo "2" > /proc/sys/net/ipv6/conf/$INET_IFACE/accept_ra
fi
if $WITH_VPN; then
  echo "2" > /proc/sys/net/ipv6/conf/$VPN_IFACE/accept_ra
fi
######################################################################
#####
for i in $IPTABLES $IP6TABLES; do
  #
  # 4. rules set up.
  #
  ######
  # 4.1 Filter table
  #
  #
  # 4.1.1 Set policies
  #
  #
  $i -P INPUT DROP
  $i -P OUTPUT DROP
  $i -P FORWARD DROP

  #
  # 4.1.2 Create userspecified chains
  #
  #
  $i -N bad_tcp_packets

  #
  # Create separate chains for ICMP, TCP and UDP to traverse
  #
  #
  $i -N allowed
  $i -N tcp_packets
  $i -N udp_packets
  $i -N icmp_packets
  $i -N logging

  #
  # 4.1.3 Create content in userspecified chains
  #
  #
  #/*TODO*/ need more information about "SYN,FIN SYN,FIN" and "SYN,RST SYN,RST"
  $i -A bad_tcp_packets -p tcp --tcp-flags ALL ACK,RST,SYN,FIN -m \
      conntrack --ctstate NEW -j REJECT --reject-with tcp-reset
  $i -A bad_tcp_packets -p tcp --tcp-flags SYN,RST SYN,RST -m \
      conntrack --ctstate NEW -j REJECT --reject-with tcp-reset
  $i -A bad_tcp_packets -p tcp --tcp-flags SYN,FIN SYN,FIN -m \
      conntrack --ctstate NEW -j REJECT --reject-with tcp-reset
  $i -A bad_tcp_packets -p tcp --tcp-flags SYN,ACK SYN,ACK -m \
      conntrack --ctstate NEW -j REJECT --reject-with tcp-reset
  $i -A bad_tcp_packets -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
#   $i -A bad_tcp_packets -p tcp ! --syn -m conntrack --ctstate NEW -j logging
  $i -A bad_tcp_packets -p tcp -m conntrack --ctstate INVALID -j DROP

  #
  # allowed chain
  $i -A allowed -p TCP --syn -j ACCEPT
  $i -A allowed -p TCP -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
  $i -A allowed -p TCP -j DROP

  #
  # TCP rules
  ##rtorrent
  $i -A tcp_packets -p TCP -m multiport --dport 8650:8655 -j allowed
  ##ktorrent
  $i -A tcp_packets -p TCP -m multiport --dport 6882:6884 -j allowed
  ##ktorrent_10.0.0.9
  $i -A tcp_packets -p TCP -m multiport --dport 6886:6890 -j allowed
  ##amule
  $i -A tcp_packets -p TCP -m multiport --dport 4661:4672,50000 -j allowed
  ##proftpd
  # $i -A tcp_packets -p TCP -m multiport --dport 20,21 -j allowed
  ##ssh
  $i -A tcp_packets -p TCP --dport 22 -j allowed
  ##sftp
  $i -A tcp_packets -p TCP --dport 115 -j allowed
  ##pptp
  $i -A INPUT -p GRE -j ACCEPT
  $i -A INPUT -p 47 -j ACCEPT
  $i -A tcp_packets -p TCP -m multiport --dport 47,1723 -j allowed
  ##apache
  # $i -A tcp_packets -p TCP -m multiport --dport 80,8080:8081,443 -j allowed
  #same as previous but prevent DoS attack
  $i -A tcp_packets -p TCP -m multiport --dport 80,8080:8081,443 -m limit --limit 25/m --limit-burst 100 -j allowed
  ##messengers
  $i -A tcp_packets -p TCP -m multiport --dport 5180:5190,5223:5225,8222:8223,9000:9005,22397:22399 -j allowed
  ##C610A IP
  $i -A tcp_packets -p TCP -m multiport --dport 5060:5076,3478,11024,5004:5020 -j allowed
  # ##SAMBA
  # $i -A tcp_packets -p TCP -m multiport --dport 135:139,445 -j allowed

  ##IDENT. Authentication Service / Identification Protocol
  # just for sure
  $i -A tcp_packets -p TCP --dport 113 -j allowed

  #
  # UDP ports
  #
  #
  ##rtorrent
  $i -A udp_packets -p UDP -m multiport --dport 8650:8655 -j ACCEPT
  ##ktorrent
  $i -A udp_packets -p UDP -m multiport --dport 6882:6884 -j ACCEPT
  ##ktorrent_10.0.0.9
  $i -A udp_packets -p UDP -m multiport --dport 6886:6890 -j ACCEPT
  ##amule
  $i -A udp_packets -p UDP -m multiport --dport 4661:4672,50000 -j ACCEPT
  ##proftpd
  # $i -A udp_packets -p UDP -m multiport --dport 20,21 -j ACCEPT
  ##ssh
  $i -A udp_packets -p UDP --dport 22 -j ACCEPT
  ##mosh
  $i -A udp_packets -p UDP -m multiport --dport 60000:61000 -j ACCEPT
  ##sftp
  $i -A udp_packets -p UDP --dport 115 -j ACCEPT
  ##pptp
  $i -A udp_packets -p UDP -m multiport --dport 47,1723 -j ACCEPT
  ##apache
  $i -A udp_packets -p UDP -m multiport --dport 80,8080:8081,443 -j ACCEPT
  ##messengers
  $i -A udp_packets -p UDP -m multiport --dport 5180:5190,5223:5225,8222:8223,9000:9005,22397:22399 -j ACCEPT
  ##C610A IP
  $i -A udp_packets -p UDP -m multiport --dport 5060:5076,3478,11024,5004:5020 -j ACCEPT
  # ##SAMBA
  # $i -A udp_packets -p UDP -m multiport --dport 135:139,445 -j ACCEPT

  ##IDENT. Authentication Service / Identification Protocol
  # just for sure
  $i -A udp_packets -p UDP --dport 113 -j ACCEPT

  #
  # LOG rules
  #
  #
  $i -A logging -p tcp ! --syn -m conntrack --ctstate NEW -j LOG \
      -m limit --limit 12/h --limit-burst 5 --log-prefix "New not syn:"
  $i -A logging -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
  $i -A logging -m limit --limit 12/h --limit-burst 5 -j LOG \
      --log-level 4 --log-prefix "IPT-Dropped: "
  $i -A logging -j DROP
done


# In Microsoft Networks you will be swamped by broadcasts. These lines
# will prevent them from showing up in the logs.
$IPTABLES  -A udp_packets -p UDP -i $LAN_IFACE_EXT -d $GLOBAL_BROADCAST --dport 135:139 -j DROP
$IPTABLES  -A udp_packets -p UDP -i $LAN_IFACE_EXT -d $GLOBAL_BROADCAST --dport 67:68 -j DROP

if $WITH_INET; then
  $IPTABLES  -A udp_packets -p UDP -i $INET_IFACE -d $GLOBAL_BROADCAST --dport 135:139 -j DROP
  $IPTABLES  -A udp_packets -p UDP -i $INET_IFACE -d $GLOBAL_BROADCAST --dport 67:68 -j DROP
fi

if $WITH_VPN; then
  $IPTABLES  -A udp_packets -p UDP -i $VPN_IFACE -d $GLOBAL_BROADCAST --dport 135:139 -j DROP
  $IPTABLES  -A udp_packets -p UDP -i $VPN_IFACE -d $GLOBAL_BROADCAST --dport 67:68 -j DROP
fi

$IPTABLES  -A icmp_packets -p ICMP --icmp-type 8 --match limit --limit 30/minute -j ACCEPT
$IP6TABLES -A icmp_packets -p ICMPv6 --icmpv6-type 128 --match limit --limit 30/minute -j ACCEPT

$IPTABLES  -A icmp_packets -p ICMP -j ACCEPT
$IP6TABLES -A icmp_packets -p ICMPv6 -j ACCEPT


#
# 4.1.4 INPUT chain

# Disable processing of any RH0 packet
# Which could allow a ping-pong of packets
$IP6TABLES -A INPUT -m rt --rt-type 0 -j DROP

$IPTABLES  -A INPUT -p tcp -j bad_tcp_packets
$IP6TABLES -A INPUT -p tcp -j bad_tcp_packets

$IPTABLES  -A INPUT -i $LAN_IFACE_EXT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

if $WITH_INET; then
  $IPTABLES  -A INPUT -i $INET_IFACE -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
fi

if $WITH_VPN; then
  $IPTABLES  -A INPUT -i $VPN_IFACE -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
fi

# allow ipv6 in ipv4
$IPTABLES  -A INPUT -p ipv6 -j ACCEPT

$IPTABLES  -A INPUT -i $LO_IFACE -j ACCEPT
$IP6TABLES -A INPUT -i $LO_IFACE -j ACCEPT

$IPTABLES  -A INPUT -i $LAN_IFACE_INT -j ACCEPT
$IP6TABLES -A INPUT -i $LAN_IFACE_INT -j ACCEPT
for i in $IFACES_IN_BRIDGE; do
  for j in $IPTABLES $IP6TABLES; do
    $j -A INPUT -i $i -j ACCEPT
  done
done

#
# Multicast DNS
#
#
$IPTABLES -A INPUT -m conntrack --ctstate NEW -m udp -p udp --dport 5353 -d 224.0.0.251 -j ACCEPT
$IP6TABLES -A INPUT -m conntrack --ctstate NEW -m udp -p udp --dport 5353 -d ff02::00fb -j ACCEPT

#
# Rules for incoming packets from the internet.
#
#
$IPTABLES -A INPUT -p TCP -i $LAN_IFACE_EXT -j tcp_packets
$IP6TABLES -A INPUT -p TCP -i $LAN_IFACE_EXT -j tcp_packets
$IPTABLES -A INPUT -p UDP -i $LAN_IFACE_EXT -j udp_packets
$IP6TABLES -A INPUT -p UDP -i $LAN_IFACE_EXT -j udp_packets
$IPTABLES  -A INPUT -p ICMP -i $LAN_IFACE_EXT -j icmp_packets
$IP6TABLES -A INPUT -p ICMPv6 -i $LAN_IFACE_EXT -j icmp_packets

if $WITH_INET; then
  $IPTABLES  -A INPUT -p TCP -i $INET_IFACE -j tcp_packets
  $IP6TABLES -A INPUT -p TCP -i $INET_IFACE -j tcp_packets
  $IPTABLES  -A INPUT -p UDP -i $INET_IFACE -j udp_packets
  $IP6TABLES -A INPUT -p UDP -i $INET_IFACE -j udp_packets
  $IPTABLES  -A INPUT -p ICMP -i $INET_IFACE -j icmp_packets
  $IP6TABLES -A INPUT -p ICMPv6 -i $INET_IFACE -j icmp_packets
fi

#
# If you have a Microsoft Network on the outside of your firewall, you may
# also get flooded by Multicasts. We drop them so we do not get flooded by
# logs
$IPTABLES -A INPUT -i $LAN_IFACE_EXT -d 224.0.0.0/8 -j DROP
if $WITH_INET; then
  $IPTABLES -A INPUT -i $INET_IFACE -d 224.0.0.0/8 -j DROP
fi
if $WITH_VPN; then
  $IPTABLES -A INPUT -i $VPN_IFACE -d 224.0.0.0/8 -j DROP
fi
#
# Log weird packets that don't match the above.
$IPTABLES  -A INPUT -j logging
$IP6TABLES -A INPUT -j logging

#
# 4.1.5 FORWARD chain
#
#

# Disable processing of any RH0 packet
# Which could allow a ping-pong of packets
$IP6TABLES -A FORWARD -m rt --rt-type 0 -j DROP


$IPTABLES  -A FORWARD -p tcp -j bad_tcp_packets
$IP6TABLES -A FORWARD -p tcp -j bad_tcp_packets

$IPTABLES  -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
$IP6TABLES -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

#Allow some  special range
$IP6TABLES -A FORWARD -s ff00::/8 -j ACCEPT
$IP6TABLES -A FORWARD -d ff00::/8 -j ACCEPT

#Explicit rule for ICMPv6 needed for ipv6
$IP6TABLES -A FORWARD -p ICMPv6 -j ACCEPT

#
# Accept the packets we actually want to forward
$IPTABLES  -A FORWARD -i $LO_IFACE -j ACCEPT
$IP6TABLES -A FORWARD -i $LO_IFACE -j ACCEPT
# $IPTABLES  -A FORWARD -o $LO_IFACE -j ACCEPT
# $IP6TABLES -A FORWARD -o $LO_IFACE -j ACCEPT
$IPTABLES  -A FORWARD -i $LAN_IFACE_INT -j ACCEPT
$IP6TABLES -A FORWARD -i $LAN_IFACE_INT -j ACCEPT
# $IPTABLES  -A FORWARD -o $LAN_IFACE_INT -j ACCEPT
# $IP6TABLES -A FORWARD -o $LAN_IFACE_INT -j ACCEPT

for i in $IFACES_IN_BRIDGE; do
  for j in $IPTABLES $IP6TABLES; do
    for k in o i; do
      $j -A FORWARD -$k $i -j ACCEPT
    done
  done
done

# $IPTABLES  -A FORWARD -i $LAN_IFACE_EXT -j ACCEPT
# $IP6TABLES -A FORWARD -i $LAN_IFACE_EXT -j ACCEPT
$IPTABLES  -A FORWARD -o $LAN_IFACE_EXT -j ACCEPT
$IP6TABLES -A FORWARD -o $LAN_IFACE_EXT -j ACCEPT

if $WITH_INET; then
#   $IPTABLES  -A FORWARD -i $INET_IFACE -j ACCEPT
#   $IP6TABLES -A FORWARD -i $INET_IFACE -j ACCEPT
  $IPTABLES  -A FORWARD -o $INET_IFACE -j ACCEPT
  $IP6TABLES -A FORWARD -o $INET_IFACE -j ACCEPT
fi

if $WITH_VPN; then
#   $IPTABLES  -A FORWARD -i $INET_IFACE -j ACCEPT
#   $IP6TABLES -A FORWARD -i $INET_IFACE -j ACCEPT
  $IPTABLES  -A FORWARD -o $VPN_IFACE -j ACCEPT
  $IP6TABLES -A FORWARD -o $VPN_IFACE -j ACCEPT
fi

## TODO Conflicts with miniupnpd as it inserts his rules at the end of the list
# $IPTABLES  -A FORWARD -j logging
# $IP6TABLES -A FORWARD -j logging

#
# 4.1.6 OUTPUT chain
$IPTABLES  -A OUTPUT -p tcp -j bad_tcp_packets
$IP6TABLES -A OUTPUT -p tcp -j bad_tcp_packets

$IPTABLES  -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
$IP6TABLES -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

#Explicit rule for ICMPv6 needed for ipv6
$IP6TABLES -A OUTPUT -p ICMPv6 -j ACCEPT

$IPTABLES  -A OUTPUT -o $LO_IFACE -j ACCEPT
$IP6TABLES -A OUTPUT -o $LO_IFACE -j ACCEPT
$IPTABLES  -A OUTPUT -o $LAN_IFACE_INT -j ACCEPT
$IP6TABLES -A OUTPUT -o $LAN_IFACE_INT -j ACCEPT

for i in $IFACES_IN_BRIDGE; do
  for j in $IPTABLES $IP6TABLES; do
    $j -A OUTPUT -o $i -j ACCEPT
  done
done


$IPTABLES  -A OUTPUT -o $LAN_IFACE_EXT -j ACCEPT
$IP6TABLES -A OUTPUT -o $LAN_IFACE_EXT -j ACCEPT

if $WITH_INET; then
  $IPTABLES  -A OUTPUT -o $INET_IFACE -j ACCEPT
  $IP6TABLES -A OUTPUT -o $INET_IFACE -j ACCEPT
fi

if $WITH_VPN; then
  $IPTABLES  -A OUTPUT -o $VPN_IFACE -j ACCEPT
  $IP6TABLES -A OUTPUT -o $VPN_IFACE -j ACCEPT
fi

#
# Log weird packets that don't match the above.
$IPTABLES  -A OUTPUT -j logging
$IP6TABLES -A OUTPUT -j logging

######
# 4.2 nat table
#
#
# 4.2.2 PREROUTING chain
#
#
##aMule
$IPTABLES -t nat -A PREROUTING -i $LAN_IFACE_EXT -p tcp -m multiport --dport 4661:4672 -j DNAT --to-destination 10.0.0.2
$IPTABLES -t nat -A PREROUTING -i $LAN_IFACE_EXT -p udp -m multiport --dport 4661:4672 -j DNAT --to-destination 10.0.0.2
##rtorrent
$IPTABLES -t nat -A PREROUTING -i $LAN_IFACE_EXT -p tcp -m multiport --dport 8650:8655,6882:6884 -j DNAT --to-destination 10.0.0.2
$IPTABLES -t nat -A PREROUTING -i $LAN_IFACE_EXT -p udp -m multiport --dport 8650:8655,6882:6884 -j DNAT --to-destination 10.0.0.2
##messengers
$IPTABLES -t nat -A PREROUTING -i $LAN_IFACE_EXT -p tcp -m multiport --dport 5180:5190,5223:5225,8222:8223,9000:9005,22397:22399,48628 -j DNAT --to-destination 10.0.0.2
$IPTABLES -t nat -A PREROUTING -i $LAN_IFACE_EXT -p udp -m multiport --dport 5180:5190,5223:5225,8222:8223,9000:9005,22397:22399,48628 -j DNAT --to-destination 10.0.0.2
#Forward port for ssh to nrndda_core
$IPTABLES -t nat -A PREROUTING -i $LAN_IFACE_EXT -p tcp --dport 11111 -j DNAT --to-destination 10.0.0.2:22
$IPTABLES -t nat -A PREROUTING -i $LAN_IFACE_EXT -p udp --dport 11111 -j DNAT --to-destination 10.0.0.2:22
#Forward port for pptp to nrndda_core
$IPTABLES -t nat -A PREROUTING -i $LAN_IFACE_EXT -p tcp -m multiport --dport 47,1723 -j DNAT --to-destination 10.0.0.2
$IPTABLES -t nat -A PREROUTING -i $LAN_IFACE_EXT -p udp -m multiport --dport 47,1723 -j DNAT --to-destination 10.0.0.2
##C610A IP
$IPTABLES -t nat -A PREROUTING -i $LAN_IFACE_EXT -p tcp -m multiport --dport 5060:5076,3478,11024,5004:5020,10000:20000 -j DNAT --to-destination 10.0.0.3
$IPTABLES -t nat -A PREROUTING -i $LAN_IFACE_EXT -p udp -m multiport --dport 5060:5076,3478,11024,5004:5020,10000:20000 -j DNAT --to-destination 10.0.0.3
if $WITH_INET; then
  ##aMule
  $IPTABLES -t nat -A PREROUTING -i $INET_IFACE -p tcp -m multiport --dport 4661:4672 -j DNAT --to-destination 10.0.0.2
  $IPTABLES -t nat -A PREROUTING -i $INET_IFACE -p udp -m multiport --dport 4661:4672 -j DNAT --to-destination 10.0.0.2
  ##rtorrent
  $IPTABLES -t nat -A PREROUTING -i $INET_IFACE -p tcp -m multiport --dport 8650:8655,6882:6884 -j DNAT --to-destination 10.0.0.2
  $IPTABLES -t nat -A PREROUTING -i $INET_IFACE -p udp -m multiport --dport 8650:8655,6882:6884 -j DNAT --to-destination 10.0.0.2
  ##messengers
  $IPTABLES -t nat -A PREROUTING -i $INET_IFACE -p tcp -m multiport --dport 5180:5190,5223:5225,8222:8223,9000:9005,22397:22399 -j DNAT --to-destination 10.0.0.2
  $IPTABLES -t nat -A PREROUTING -i $INET_IFACE -p udp -m multiport --dport 5180:5190,5223:5225,8222:8223,9000:9005,22397:22399 -j DNAT --to-destination 10.0.0.2
  #Forward port for ssh to nrndda_core
  $IPTABLES -t nat -A PREROUTING -i $INET_IFACE -p tcp --dport 11111 -j DNAT --to-destination 10.0.0.2:22
  $IPTABLES -t nat -A PREROUTING -i $INET_IFACE -p udp --dport 11111 -j DNAT --to-destination 10.0.0.2:22
  #Forward port for pptp to nrndda_core
  $IPTABLES -t nat -A PREROUTING -i $INET_IFACE -p tcp -m multiport --dport 47,1723 -j DNAT --to-destination 10.0.0.2
  $IPTABLES -t nat -A PREROUTING -i $INET_IFACE -p udp -m multiport --dport 47,1723 -j DNAT --to-destination 10.0.0.2
  ##C610A IP
  $IPTABLES -t nat -A PREROUTING -i $INET_IFACE -p tcp -m multiport --dport 5060:5076,3478,11024,5004:5020,10000:20000 -j DNAT --to-destination 10.0.0.3
  $IPTABLES -t nat -A PREROUTING -i $INET_IFACE -p udp -m multiport --dport 5060:5076,3478,11024,5004:5020,10000:20000 -j DNAT --to-destination 10.0.0.3
fi
if $WITH_VPN; then
  ##aMule
  $IPTABLES -t nat -A PREROUTING -i $VPN_IFACE -p tcp -m multiport --dport 4661:4672 -j DNAT --to-destination 10.0.0.2
  $IPTABLES -t nat -A PREROUTING -i $VPN_IFACE -p udp -m multiport --dport 4661:4672 -j DNAT --to-destination 10.0.0.2
  ##rtorrent
  $IPTABLES -t nat -A PREROUTING -i $VPN_IFACE -p tcp -m multiport --dport 8650:8655,6882:6884 -j DNAT --to-destination 10.0.0.2
  $IPTABLES -t nat -A PREROUTING -i $VPN_IFACE -p udp -m multiport --dport 8650:8655,6882:6884 -j DNAT --to-destination 10.0.0.2
  ##messengers
  $IPTABLES -t nat -A PREROUTING -i $VPN_IFACE -p tcp -m multiport --dport 5180:5190,5223:5225,8222:8223,9000:9005,22397:22399 -j DNAT --to-destination 10.0.0.2
  $IPTABLES -t nat -A PREROUTING -i $VPN_IFACE -p udp -m multiport --dport 5180:5190,5223:5225,8222:8223,9000:9005,22397:22399 -j DNAT --to-destination 10.0.0.2
  #Forward port for ssh to nrndda_core
  $IPTABLES -t nat -A PREROUTING -i $VPN_IFACE -p tcp --dport 11111 -j DNAT --to-destination 10.0.0.2:22
  $IPTABLES -t nat -A PREROUTING -i $VPN_IFACE -p udp --dport 11111 -j DNAT --to-destination 10.0.0.2:22
  #Forward port for pptp to nrndda_core
  $IPTABLES -t nat -A PREROUTING -i $VPN_IFACE -p tcp -m multiport --dport 47,1723 -j DNAT --to-destination 10.0.0.2
  $IPTABLES -t nat -A PREROUTING -i $VPN_IFACE -p udp -m multiport --dport 47,1723 -j DNAT --to-destination 10.0.0.2
  ##C610A IP
  $IPTABLES -t nat -A PREROUTING -i $VPN_IFACE -p tcp -m multiport --dport 5060:5076,3478,11024,5004:5020,10000:20000 -j DNAT --to-destination 10.0.0.3
  $IPTABLES -t nat -A PREROUTING -i $VPN_IFACE -p udp -m multiport --dport 5060:5076,3478,11024,5004:5020,10000:20000 -j DNAT --to-destination 10.0.0.3
fi
#
# 4.2.2 POSTROUTING chain
#
#

$IPTABLES  -t nat -A POSTROUTING -o $LAN_IFACE_EXT -j MASQUERADE
$IP6TABLES -t nat -A POSTROUTING -o $LAN_IFACE_EXT -j MASQUERADE
if $WITH_INET; then
  $IPTABLES  -t nat -A POSTROUTING -o $INET_IFACE -j MASQUERADE
  $IP6TABLES -t nat -A POSTROUTING -o $INET_IFACE -j MASQUERADE
fi
if $WITH_VPN; then
  $IPTABLES  -t nat -A POSTROUTING -o $VPN_IFACE -j MASQUERADE
  $IP6TABLES -t nat -A POSTROUTING -o $VPN_IFACE -j MASQUERADE
fi
