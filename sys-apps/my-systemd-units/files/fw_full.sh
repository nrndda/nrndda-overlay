#!/bin/sh
IPTABLES="/sbin/iptables"
IP6TABLES="/sbin/ip6tables"
IFCONFIG='/bin/ifconfig'

# WITH_INET=$1

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

function get_addr()
{
#    HEAD='head -2';
#    TAIL='tail -1';
#    CUT='cut -d: -f2';
#    IP=`$IFCONFIG $1 | $HEAD | $TAIL | awk '{print $2}' | $CUT`;
  IP=`$IFCONFIG $1 | grep -i "inet " | awk '{print $2}'`;
   echo $IP;
}

function get_addrv6()
{
  IFCONFIG='/bin/ifconfig';
  #IP=""
  #for i in `ifconfig $1 | grep -i "inet6 " | awk '{print $2}'`; do IP+=" " ; IP+=$i; done
  IP=`$IFCONFIG $1 | grep -i "inet6 " | head -1 | awk '{print $2}'`;
  echo $IP;
}

function get_addrv6_all()
{
  IFCONFIG='/bin/ifconfig';
  IP=""
  for i in `ifconfig $1 | grep -i "inet6 " | awk '{print $2}'`; do IP+=" " ; IP+=$i; done
  #IP=`$IFCONFIG $1 | grep -i "inet6 " | head -1 | awk '{print $2}'`;
  echo $IP;
}

function get_my_prefix()
{
  RDISC6='/usr/bin/rdisc6';
  $RDISC6 -q1 $1
}

function get_netmask()
{
#    HEAD='head -2';
#    TAIL='tail -1';
#    CUT='cut -d: -f2';
#    IP=`$IFCONFIG $1 | $HEAD | $TAIL | awk '{print $4}' | $CUT`;
  IP=`$IFCONFIG $1 | grep -i "inet " | awk '{print $4}'`;
   echo $IP;
}

function get_broadcast()
{
#    HEAD='head -2';
#    TAIL='tail -1';
#    CUT='cut -d: -f2';
#    IP=`$IFCONFIG $1 | $HEAD | $TAIL | awk '{print $6}' | $CUT`;
  IP=`$IFCONFIG $1 | grep -i "inet " | awk '{print $6}'`;
   echo $IP;
}

function get_dev()
{
  sytemd_dir="/etc/systemd/system/network.target.wants"
  DEV=`ls $sytemd_dir/$1 | cut -d "@" -f 2- | cut -d "." -f -1`
  echo $DEV;
}

function get_ext_lan_if()
{
  IF=get_dev(ext_lan\@enp*)
  echo $IF;
}

function get_inet_if()
{
  IF=get_dev(inet\@ppp*)
  echo $IF;
}
######################################################################
#####
#
# 1. Configuration options.
#
GLOBAL_BROADCAST="255.255.255.255"
IPv6_LINK_LOCAL="fe80::/10"
# 1.1 Internal Local Area Network configuration.
#
#
LAN_IFACE_INT="br0"
LAN_IP_INT=`get_addr $LAN_IFACE_INT`
LAN_IPv6_INT=`get_addrv6 $LAN_IFACE_INT`
LAN_IPv6_INT_ALL=`get_addrv6_all $LAN_IFACE_INT`
LAN_PREFIX_INT=`get_my_prefix $LAN_IFACE_INT`
LAN_NETMASK_INT=`get_netmask $LAN_IFACE_INT`
LAN_BROADCAST_INT=`get_broadcast $LAN_IFACE_INT`
LAN_IP_RANGE_INT="$LAN_IP_INT/$LAN_NETMASK_INT"
# IFACE_IN_BRIDGE="enp2s0 wlp3s7 wlp0s19f2u4"

#
# 1.2 External Local Area Network configuration.
#
#
LAN_IFACE_EXT=`get_ext_lan_if`
LAN_IP_EXT=`get_addr $LAN_IFACE_EXT`
LAN_IPv6_EXT=`get_addrv6 $LAN_IFACE_EXT`
LAN_IPv6_EXT_ALL=`get_addrv6_all $LAN_IFACE_EXT`
LAN_NETMASK_EXT=`get_netmask $LAN_IFACE_EXT`
LAN_BROADCAST_EXT=`get_broadcast $LAN_IFACE_EXT`
LAN_IP_RANGE_EXT="$LAN_IP_EXT/$LAN_NETMASK_EXT"

#
# 1.3 Internet Configuration.
#
#
INET_IFACE=`get_inet_if`
WITH_INET=`$IFCONFIG | grep -q $INET_IFACE`
INET_IP=`get_addr $INET_IFACE`
INET_IPv6=`get_addrv6 $INET_IFACE`
INET_IPv6_ALL=`get_addrv6_all $INET_IFACE`
INET_NETMASK=`get_netmask $INET_IFACE`
INET_PREFIX=`get_my_prefix $INET_IFACE`
INET_BROADCAST=`get_broadcast $INET_IFACE`
INET_IP_RANGE="$INET_IP/$INET_NETMASK"

#
# 1.3 VPN Configuration.
#
#
# VPN_IP="192.168.2.1"
# VPN_IP_RANGE="192.168.2.0/24"
# VPN_IFACE="ppp+"

#
# 1.4 Localhost Configuration.
#
#
LO_IFACE="lo"
LO_IP=`get_addr $LO_IFACE`
LO_IPv6=`get_addrv6 $LO_IFACE`
######################################################################
flush
# Once tables wasn't flushed by one exec of this command.
# Run it twice just to be sure.
flush
######################################################################
#####
#
# 2. Module loading.
#
#
/sbin/depmod -a
#
# 2.1 Required modules
#
# /sbin/modprobe ip_tables
# /sbin/modprobe ip_conntrack
# /sbin/modprobe iptable_filter
# /sbin/modprobe iptable_mangle
# /sbin/modprobe iptable_nat
# /sbin/modprobe ipt_LOG
# /sbin/modprobe ipt_limit
# /sbin/modprobe ipt_state
#
# 2.2 Non-Required modules
#
#/sbin/modprobe ipt_owner
#/sbin/modprobe ipt_REJECT
#/sbin/modprobe ipt_MASQUERADE
# /sbin/modprobe ip_conntrack_ftp
# /sbin/modprobe ip_conntrack_irc
# /sbin/modprobe ip_nat_ftp
# /sbin/modprobe ip_nat_irc
######################################################################
#####
#
# 3. /proc set up.
#
#
# 3.1 Required proc configuration
#
echo "1" > /proc/sys/net/ipv4/ip_forward
echo "1" > /proc/sys/net/ipv6/conf/all/forwarding
echo "1" > /proc/sys/net/ipv6/conf/default/forwarding
#
# 3.2 Non-Required proc configuration
#
#echo "1" > /proc/sys/net/ipv4/conf/all/rp_filter
#echo "1" > /proc/sys/net/ipv4/conf/all/proxy_arp
#echo "1" > /proc/sys/net/ipv4/ip_dynaddr
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
      state --state NEW -j REJECT --reject-with tcp-reset
  $i -A bad_tcp_packets -p tcp --tcp-flags SYN,RST SYN,RST -m \
      state --state NEW -j REJECT --reject-with tcp-reset
  $i -A bad_tcp_packets -p tcp --tcp-flags SYN,FIN SYN,FIN -m \
      state --state NEW -j REJECT --reject-with tcp-reset
  $i -A bad_tcp_packets -p tcp --tcp-flags SYN,ACK SYN,ACK -m \
      state --state NEW -j REJECT --reject-with tcp-reset
  $i -A bad_tcp_packets -p tcp ! --syn -m state --state NEW -j DROP
#   $i -A bad_tcp_packets -p tcp ! --syn -m state --state NEW -j logging
  $i -A bad_tcp_packets -p tcp -m state --state INVALID -j DROP

  #
  # allowed chain
  #
  #
  $i -A allowed -p TCP --syn -j ACCEPT
  $i -A allowed -p TCP -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
  $i -A allowed -p TCP -j DROP

  #
  # TCP rules
  #
  #
  ##rtorrent
  $i -A tcp_packets -p TCP -m multiport --dport 8650:8655 -j allowed
  ##ktorrent
  $i -A tcp_packets -p TCP -m multiport --dport 6882:6884 -j allowed
  ##ktorrent_10.0.0.9
  $i -A tcp_packets -p TCP -m multiport --dport 6886:6890 -j allowed
  ##amule
  # $i -A tcp_packets -p TCP -m multiport --dport 4662:4672,50000 -j allowed
  ##proftpd
  # $i -A tcp_packets -p TCP -m multiport --dport 20,21 -j allowed
  ##ssh
  $i -A tcp_packets -p TCP --dport 22 -j allowed
  ##sftp
  $i -A tcp_packets -p TCP --dport 115 -j allowed
  ##apache
#   $i -A tcp_packets -p TCP -m multiport --dport 80,8080:8081,443 -j allowed
  #same as previous but prevent DoS attack
  $i -A tcp_packets -p TCP -m multiport --dport 80,8080:8081,443 -m limit --limit 25/m --limit-burst 100 -j allowed
  ##messengers
  $i -A tcp_packets -p TCP -m multiport --dport 5180:5190,5223:5225,8222:8223,9000:9005,22397:22399 -j allowed
  ##C610A IP
  $i -A tcp_packets -p TCP -m multiport --dport 5060:5076,3478,5004:5020 -j allowed
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
  # $i -A udp_packets -p UDP -m multiport --dport 4662:4672,50000 -j ACCEPT
  ##proftpd
  # $i -A udp_packets -p UDP -m multiport --dport 20,21 -j ACCEPT
  ##ssh
  $i -A udp_packets -p UDP --dport 22 -j ACCEPT
  ##sftp
  $i -A udp_packets -p UDP --dport 115 -j ACCEPT
  ##apache
  $i -A udp_packets -p UDP -m multiport --dport 80,8080:8081,443 -j ACCEPT
  ##messengers
  $i -A udp_packets -p UDP -m multiport --dport 5180:5190,5223:5225,8222:8223,9000:9005,22397:22399 -j ACCEPT
  ##C610A IP
  $i -A udp_packets -p UDP -m multiport --dport 5060:5076,3478,5004:5020 -j ACCEPT
  # ##SAMBA
  # $i -A udp_packets -p UDP -m multiport --dport 135:139,445 -j ACCEPT

  ##IDENT. Authentication Service / Identification Protocol
  # just for sure
  $i -A udp_packets -p UDP --dport 113 -j ACCEPT

  #
  # LOG rules
  #
  #
  $i -A logging -p tcp ! --syn -m state --state NEW -j LOG \
      -m limit --limit 12/h --limit-burst 5 --log-prefix "New not syn:"
  $i -A logging -p tcp ! --syn -m state --state NEW -j DROP
  $i -A logging -m limit --limit 12/h --limit-burst 5 -j LOG \
      --log-level 4 --log-prefix "IPT-Dropped: "
  $i -A logging -j DROP
done


# In Microsoft Networks you will be swamped by broadcasts. These lines 
# will prevent them from showing up in the logs.
#
$IPTABLES  -A udp_packets -p UDP -i $LAN_IFACE_EXT -d $LAN_BROADCAST_EXT --dport 135:139 -j DROP
# $IP6TABLES -A udp_packets -p UDP -i $LAN_IFACE_EXT --dport 135:139 -j DROP
$IPTABLES  -A udp_packets -p UDP -i $LAN_IFACE_EXT -d $GLOBAL_BROADCAST --dport 67:68 -j DROP
# $IP6TABLES -A udp_packets -p UDP -i $LAN_IFACE_EXT --dport 67:68 -j DROP
$IPTABLES  -A udp_packets -p UDP -i $LAN_IFACE_EXT -d $LAN_IP_INT --sport 123 --dport 123 -j DROP
for i in $LAN_IPv6_INT_ALL; do
  $IP6TABLES -A udp_packets -p UDP -i $LAN_IFACE_EXT -d $i --sport 123 --dport 123 -j DROP
  if $WITH_INET; then
    $IP6TABLES -A udp_packets -p UDP -i $INET_IFACE -d $i --sport 123 --dport 123 -j DROP
  fi
done
if $WITH_INET; then
  $IPTABLES  -A udp_packets -p UDP -i $INET_IFACE -d $INET_BROADCAST --dport 135:139 -j DROP
#   $IP6TABLES -A udp_packets -p UDP -i $INET_IFACE --dport 135:139 -j DROP
  $IPTABLES  -A udp_packets -p UDP -i $INET_IFACE -d $INET_BROADCAST --dport 67:68 -j DROP
#   $IP6TABLES -A udp_packets -p UDP -i $INET_IFACE --dport 67:68 -j DROP
$IPTABLES  -A udp_packets -p UDP -i $INET_IFACE -d $LAN_IP_INT --sport 123 --dport 123 -j DROP
fi

#
# If we get DHCP requests from the Outside of our network, our logs will
# be swamped as well. This rule will block them from getting logged.
#
#
$IPTABLES  -A udp_packets -p UDP -i $LAN_IFACE_EXT -d $LAN_BROADCAST_EXT --dport 67:68 -j DROP
# $IP6TABLES -A udp_packets -p UDP -i $LAN_IFACE_EXT --dport 67:68 -j DROP

#
# ICMP rules
#
#
# ## ICMP Type 0 “Echo Reply"
# $IPTABLES  -A icmp_packets -p ICMP --icmp-type 0 -j ACCEPT
# ## ICMP Type 3 “Destination Unreachable"
# $IPTABLES  -A icmp_packets -p ICMP --icmp-type 3 -j ACCEPT
# ## ICMP Type 5 “Redirect Message"
# $IPTABLES  -A icmp_packets -p ICMP --icmp-type 5 -j ACCEPT
# ## ICMP Type 11 "Time Exceeded"
# $IPTABLES  -A icmp_packets -p ICMP --icmp-type 11 -j ACCEPT
# ## ICMP Type 12 "Parameter Problem: Bad IP header"
# $IPTABLES  -A icmp_packets -p ICMP --icmp-type 12 -j ACCEPT
# ## ICMP Type 14 "Timestamp Reply"
# $IPTABLES  -A icmp_packets -p ICMP --icmp-type 14 -j ACCEPT
# ## ICMP Type 16 "Information Reply"
# $IPTABLES  -A icmp_packets -p ICMP --icmp-type 16 -j ACCEPT
# ## ICMP Type 18 "Address Mask Reply"
# $IPTABLES  -A icmp_packets -p ICMP --icmp-type 18 -j ACCEPT
# ## ICMP Type 38 "Domain Name Reply"
# $IPTABLES  -A icmp_packets -p ICMP --icmp-type 38 -j ACCEPT
# 
# ## ICMP Type 1 “Destination Unreachable”
# $IP6TABLES -A icmp_packets -p ICMPv6 --icmpv6-type 1 -j ACCEPT
# ## ICMP Type 2 “Packet Too Big”
# $IP6TABLES -A icmp_packets -p ICMPv6 --icmpv6-type 2 -j ACCEPT
# ## ICMP Type 3 “Time Exceeded”
# $IP6TABLES -A icmp_packets -p ICMPv6 --icmpv6-type 3 -j ACCEPT
# ## ICMP Type 4 “Parameter Problem”
# $IP6TABLES -A icmp_packets -p ICMPv6 --icmpv6-type 4 -j ACCEPT
# ## ICMP Type 129 “Echo Reply"
# $IP6TABLES -A icmp_packets -p ICMPv6 --icmpv6-type 129 -j ACCEPT
# ## ICMP Type 133 “Router Solicitation"
# $IP6TABLES -A icmp_packets -p ICMPv6 --icmpv6-type 133 -j ACCEPT
# ## ICMP Type 134 “Router Advertisement"
# $IP6TABLES -A icmp_packets -p ICMPv6 --icmpv6-type 134 -j ACCEPT
# ## ICMP Type 135 “Neighbor Solicitation"
# $IP6TABLES -A icmp_packets -p ICMPv6 --icmpv6-type 135 -j ACCEPT
# ## ICMP Type 136 “Neighbor Advertisement"
# $IP6TABLES -A icmp_packets -p ICMPv6 --icmpv6-type 136 -j ACCEPT
# ## ICMP Type 137 “Redirect Message"
# $IP6TABLES -A icmp_packets -p ICMPv6 --icmpv6-type 137 -j ACCEPT
# ## ICMP Type 140 “ICMP Node Information Response"
# $IP6TABLES -A icmp_packets -p ICMPv6 --icmpv6-type 140 -j ACCEPT
# ## ICMP Type 141 “Inverse Neighbor Discovery Solicitation Message"
# $IP6TABLES -A icmp_packets -p ICMPv6 --icmpv6-type 141 -j ACCEPT
# ## ICMP Type 142 “Inverse Neighbor Discovery Advertisement Message"
# $IP6TABLES -A icmp_packets -p ICMPv6 --icmpv6-type 142 -j ACCEPT
# ## ICMP Type 148 “Certification Path Solicitation"
# $IP6TABLES -A icmp_packets -p ICMPv6 --icmpv6-type 148 -j ACCEPT
# ## ICMP Type 149 “Certification Path Advertisement"
# $IP6TABLES -A icmp_packets -p ICMPv6 --icmpv6-type 149 -j ACCEPT

# $IPTABLES  -A icmp_packets -p ICMP -j REJECT --reject-with icmp-host-unreachable
# $IP6TABLES -A icmp_packets -p ICMPv6 -j REJECT --reject-with icmp6-adm-prohibited

# $IPTABLES  -A icmp_packets -p ICMP --icmp-type 8 -j REJECT --reject-with icmp-host-unreachable
# $IP6TABLES -A icmp_packets -p ICMPv6 --icmpv6-type 128 -j REJECT --reject-with icmp6-adm-prohibited

$IPTABLES  -A icmp_packets -p ICMP --icmp-type 8 --match limit --limit 30/minute -j ACCEPT
# $IP6TABLES -A icmp_packets -p ICMPv6 --icmpv6-type 128 --match limit --limit 30/minute -j ACCEPT

$IPTABLES  -A icmp_packets -p ICMP -j ACCEPT
$IP6TABLES -A icmp_packets -p ICMPv6 -j ACCEPT


#
# 4.1.4 INPUT chain
#
#
$IPTABLES  -A INPUT -p tcp -j bad_tcp_packets
$IP6TABLES -A INPUT -p tcp -j bad_tcp_packets

# Disable processing of any RH0 packet
# Which could allow a ping-pong of packets
$IP6TABLES -A INPUT -m rt --rt-type 0 -j DROP

$IPTABLES  -A INPUT -d $LAN_IP_EXT -m state --state ESTABLISHED,RELATED -j ACCEPT
for i in $LAN_IPv6_EXT_ALL; do
  $IP6TABLES -A INPUT -d $i -m state --state ESTABLISHED,RELATED -j ACCEPT
done
if $WITH_INET; then
  $IPTABLES  -A INPUT -d $INET_IP -m state --state ESTABLISHED,RELATED -j ACCEPT
  for i in $INET_IPv6_ALL; do
    $IP6TABLES -A INPUT -d $i -m state --state ESTABLISHED,RELATED -j ACCEPT
  done
fi

# allow ipv6 in ipv4
$IPTABLES  -A INPUT -p ipv6 -j ACCEPT

#
# Rules for special networks not part of the Internet
#
#
# for i in $IFACE_IN_BRIDGE; do
#   for j in $IPTABLES $IP6TABLES; do
#     $j -A INPUT -i $i -j ACCEPT
#     $j -A INPUT -m physdev --physdev-in $i -j ACCEPT
#   done
# done

$IPTABLES  -A INPUT -i $LO_IFACE -j ACCEPT
$IP6TABLES -A INPUT -i $LO_IFACE -j ACCEPT

# $IPTABLES  -A INPUT -i $LO_IFACE -s $LO_IP -j ACCEPT
# $IP6TABLES -A INPUT -i $LO_IFACE -s $LO_IPv6 -j ACCEPT
# $IPTABLES  -A INPUT -i $LO_IFACE -s $LAN_IP_INT -j ACCEPT
# for i in $LAN_IPv6_INT_ALL; do
#   $IP6TABLES -A INPUT -i $LO_IFACE -s $i -j ACCEPT
# done
# $IPTABLES  -A INPUT -i $LO_IFACE -s $LAN_IP_EXT -j ACCEPT
# for i in $LAN_IPv6_EXT_ALL; do
#   $IP6TABLES -A INPUT -i $LO_IFACE -s $i -j ACCEPT
# done
# 
# if $WITH_INET; then
#   $IPTABLES  -A INPUT -i $LO_IFACE -s $INET_IP -j ACCEPT
#   for i in $INET_IPv6_ALL; do
#     $IP6TABLES -A INPUT -i $LO_IFACE -s $i -j ACCEPT
#   done
# fi
#$IPTABLES -A INPUT -i $VPN_IFACE -s $VPN_IP_RANGE -j ACCEPT
# $IPTABLES -A INPUT -i $LO_IFACE -s $VPN_IP -j ACCEPT

$IPTABLES  -A INPUT -i $LAN_IFACE_INT -s $LAN_IP_RANGE_INT -j ACCEPT
# $IP6TABLES -A INPUT -i $LAN_IFACE_INT -s $IPv6_LINK_LOCAL -j ACCEPT
$IP6TABLES -A INPUT -s $IPv6_LINK_LOCAL -j ACCEPT

#
# Special rule for DHCP requests from LAN, which are not caught  properly
# otherwise.
#
#
$IPTABLES  -A INPUT -p UDP -i $LAN_IFACE_INT --dport 67:68 --sport 67:68 -j ACCEPT
$IP6TABLES -A INPUT -p UDP -i $LAN_IFACE_INT --dport 67:68 --sport 67:68 -j ACCEPT

#
# Multicast DNS
#
#
$IPTABLES -A INPUT -m state --state NEW -m udp -p udp --dport 5353 -d 224.0.0.251 -j ACCEPT
$IP6TABLES -A INPUT -m state --state NEW -m udp -p udp --dport 5353 -d ff02::00fb -j ACCEPT

#
# Rules for incoming packets from the internet.
#
#
$IPTABLES -A INPUT -p TCP -i $LAN_IFACE_EXT -j tcp_packets
$IPTABLES -A INPUT -p UDP -i $LAN_IFACE_EXT -j udp_packets
$IPTABLES  -A INPUT -p ICMP -i $LAN_IFACE_EXT -j icmp_packets
$IP6TABLES -A INPUT -p ICMPv6 -i $LAN_IFACE_EXT -j icmp_packets

if $WITH_INET; then
  $IPTABLES  -A INPUT -p TCP -i $INET_IFACE -j tcp_packets
  $IP6TABLES -A INPUT -p TCP -i $INET_IFACE -j tcp_packets
  $IPTABLES  -A INPUT -p UDP -i $INET_IFACE -j udp_packets
  $IP6TABLES -A INPUT -p UDP -i $INET_IFACE -j udp_packets
  $IPTABLES  -A INPUT -p ICMP -i $INET_IFACE -j icmp_packets
  $IP6TABLES -A INPUT -p ICMPv6 -i $INET_IFACE -j icmp_packets

  #Allow my prefix
  $IP6TABLES -A INPUT -i $LAN_IFACE_INT -s $LAN_PREFIX_INT -j ACCEPT
  $IP6TABLES -A INPUT -i $LO_IFACE -s $LAN_PREFIX_INT -j ACCEPT
  $IP6TABLES -A INPUT -i $LAN_IFACE_EXT -s $LAN_PREFIX_INT -j ACCEPT
  $IP6TABLES -A INPUT -i $INET_IFACE -s $LAN_PREFIX_INT -j ACCEPT
fi

#
# If you have a Microsoft Network on the outside of your firewall, you may 
# also get flooded by Multicasts. We drop them so we do not get flooded by 
# logs
#
#
$IPTABLES -A INPUT -i $LAN_IFACE_EXT -d 224.0.0.0/8 -j DROP
if $WITH_INET; then
  $IPTABLES -A INPUT -i $INET_IFACE -d 224.0.0.0/8 -j DROP
fi

#
#SQUID
#
# $IPTABLES -A INPUT -s 192.168.1.0/24 -p tcp --dport 3128 -j DROP
#$IPTABLES -A INPUT -p tcp --dport 3128 -s 192.168.2.0/24 -j ACCEPT

#
# Log weird packets that don't match the above.
#
#
$IPTABLES  -A INPUT -j logging
$IP6TABLES -A INPUT -j logging

#
# 4.1.5 FORWARD chain
#
#
$IPTABLES  -A FORWARD -p tcp -j bad_tcp_packets
$IP6TABLES -A FORWARD -p tcp -j bad_tcp_packets

$IPTABLES  -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
$IP6TABLES -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

#Allow some  special range
$IP6TABLES -A FORWARD -s ff00::/8 -j ACCEPT
$IP6TABLES -A FORWARD -d ff00::/8 -j ACCEPT

#Explicit rule for ICMPv6 needed for ipv6
$IP6TABLES -A FORWARD -p ICMPv6 -j ACCEPT

# Disable processing of any RH0 packet
# Which could allow a ping-pong of packets
$IP6TABLES -A FORWARD -m rt --rt-type 0 -j DROP

#
# Accept the packets we actually want to forward
#
#
$IPTABLES  -A FORWARD -i $LAN_IFACE_INT -s $LAN_IP_RANGE_INT -j ACCEPT
$IPTABLES  -A FORWARD -i $LAN_IFACE_INT -d $LAN_IP_RANGE_INT -j ACCEPT
$IP6TABLES -A FORWARD -i $LAN_IFACE_INT -s $IPv6_LINK_LOCAL -j ACCEPT
$IP6TABLES -A FORWARD -i $LAN_IFACE_INT -d $IPv6_LINK_LOCAL -j ACCEPT

#Allow all FORWARD traffic from internal lan interface.
$IPTABLES  -A FORWARD -i $LAN_IFACE_INT -j ACCEPT
$IP6TABLES -A FORWARD -i $LAN_IFACE_INT -j ACCEPT
# for i in $IFACE_IN_BRIDGE; do
#   for j in $IPTABLES $IP6TABLES; do
#     $j -A FORWARD -i $i -j ACCEPT;
# #     for k in $IFACE_IN_BRIDGE; do
# #       if [[ $i != $k ]];
# #       then
# #           $j -A FORWARD -m physdev --physdev-in $i \
# #               -m physdev --physdev-out $k -j ACCEPT;
# #       fi
# #     done
#   done
# done

if $WITH_INET; then
  #Allow my prefix
  $IP6TABLES -A FORWARD -i $LAN_IFACE_INT -s $LAN_PREFIX_INT -j ACCEPT
  $IP6TABLES -A FORWARD -i $LO_IFACE -s $LAN_PREFIX_INT -j ACCEPT
  $IP6TABLES -A FORWARD -i $LAN_IFACE_EXT -s $LAN_PREFIX_INT -j ACCEPT
  $IP6TABLES -A FORWARD -i $INET_IFACE -s $LAN_PREFIX_INT -j ACCEPT

  $IP6TABLES -A FORWARD -o $LAN_IFACE_INT -d $LAN_PREFIX_INT -j ACCEPT
  $IP6TABLES -A FORWARD -o $LO_IFACE -d $LAN_PREFIX_INT -j ACCEPT
  $IP6TABLES -A FORWARD -o $LAN_IFACE_EXT -d $LAN_PREFIX_INT -j ACCEPT
  $IP6TABLES -A FORWARD -o $INET_IFACE -d $LAN_PREFIX_INT -j ACCEPT

  $IP6TABLES -A FORWARD -i $INET_IFACE -o $INET_IFACE -s $LAN_PREFIX_INT -j ACCEPT
  $IP6TABLES -A FORWARD -i $INET_IFACE -o $INET_IFACE -d $LAN_PREFIX_INT -j ACCEPT
  $IP6TABLES -A FORWARD -s $LAN_PREFIX_INT -d $LAN_PREFIX_INT -j ACCEPT
  $IP6TABLES -A FORWARD -s $LAN_PREFIX_INT -j ACCEPT
  $IP6TABLES -A FORWARD -d $LAN_PREFIX_INT -j ACCEPT
fi


## Drop packates forwarded from one interface to the same
# $IPTABLES  -A FORWARD -i $LAN_IFACE_INT -o $LAN_IFACE_INT -j DROP
# $IP6TABLES -A FORWARD -i $LAN_IFACE_INT -o $LAN_IFACE_INT -j DROP
# $IPTABLES  -A FORWARD -i $LAN_IFACE_EXT -o $LAN_IFACE_EXT -j DROP
# $IP6TABLES -A FORWARD -i $LAN_IFACE_EXT -o $LAN_IFACE_EXT -j DROP
# if $WITH_INET; then
#   $IPTABLES  -A FORWARD -i $INET_IFACE -o $INET_IFACE -j DROP
#   $IP6TABLES -A FORWARD -i $INET_IFACE -o $INET_IFACE -j DROP
# fi

#
# Log weird packets that don't match the above.
#
#
## TODO Conflicts with miniupnpd as it inserts his rules at the end of the list
# $IPTABLES  -A FORWARD -j logging
# $IP6TABLES -A FORWARD -j logging

#
# 4.1.6 OUTPUT chain
#
#
$IPTABLES  -A OUTPUT -p tcp -j bad_tcp_packets
$IP6TABLES -A OUTPUT -p tcp -j bad_tcp_packets

$IPTABLES  -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$IP6TABLES -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#Explicit rule for ICMPv6 needed for ipv6
$IP6TABLES -A OUTPUT -p ICMPv6 -j ACCEPT
# if $WITH_INET; then
#   $IP6TABLES -A OUTPUT -p ICMPv6 -j ACCEPT
# fi

#
# Special OUTPUT rules to decide which IP's to allow.
#
#
# for i in $IFACE_IN_BRIDGE; do
#   for j in $IPTABLES $IP6TABLES; do
#     $j -A OUTPUT -o $i -j ACCEPT
# #     $j -A OUTPUT -m physdev --physdev-out $i -j ACCEPT
#   done
# done

$IPTABLES  -A OUTPUT -o $LO_IFACE -j ACCEPT
$IP6TABLES -A OUTPUT -o $LO_IFACE -j ACCEPT
$IPTABLES  -A OUTPUT -o $LAN_IFACE_INT -j ACCEPT
$IP6TABLES -A OUTPUT -o $LAN_IFACE_INT -j ACCEPT
$IPTABLES  -A OUTPUT -s $LO_IP -j ACCEPT
$IP6TABLES -A OUTPUT -s $LO_IPv6 -j ACCEPT
$IPTABLES  -A OUTPUT -s $LAN_IP_INT -j ACCEPT
$IP6TABLES -A OUTPUT -s $IPv6_LINK_LOCAL -j ACCEPT
for i in $LAN_IPv6_INT_ALL; do
  $IP6TABLES -A OUTPUT -s $i -j ACCEPT
done
$IPTABLES  -A OUTPUT -s $LAN_IP_EXT -j ACCEPT
for i in $LAN_IPv6_EXT_ALL; do
  $IP6TABLES -A OUTPUT -s $i -j ACCEPT
done
if $WITH_INET; then
  $IPTABLES  -A OUTPUT -s $INET_IP -j ACCEPT
  for i in $INET_IPv6_ALL; do
    $IP6TABLES -A OUTPUT -s $i -j ACCEPT
  done

  #Allow my prefix
#   $IP6TABLES -A OUTPUT -o $LAN_IFACE_INT -s $LAN_PREFIX_INT -j ACCEPT
#   $IP6TABLES -A OUTPUT -o $LO_IFACE -s $LAN_PREFIX_INT -j ACCEPT
  $IP6TABLES -A OUTPUT -o $LAN_IFACE_EXT -s $LAN_PREFIX_INT -j ACCEPT
  $IP6TABLES -A OUTPUT -o $INET_IFACE -s $LAN_PREFIX_INT -j ACCEPT
fi

#
# Log weird packets that don't match the above.
#
#
$IPTABLES  -A OUTPUT -j logging
$IP6TABLES -A OUTPUT -j logging

######
# 4.2 nat table
#
#
# 4.2.2 PREROUTING chain
#
#
$IPTABLES -t nat -A PREROUTING -i $LAN_IP_EXT -p tcp -m multiport --dport 6886:6890 -j DNAT --to-destination 10.0.0.9
$IPTABLES -t nat -A PREROUTING -i $LAN_IP_EXT -p udp -m multiport --dport 6886:6890 -j DNAT --to-destination 10.0.0.9
if $WITH_INET; then
  ##ktorrent_10.0.0.9
  $IPTABLES -t nat -A PREROUTING -i $INET_IFACE -p tcp -m multiport --dport 6886:6890 -j DNAT --to-destination 10.0.0.9
  $IPTABLES -t nat -A PREROUTING -i $INET_IFACE -p udp -m multiport --dport 6886:6890 -j DNAT --to-destination 10.0.0.9
  ##C610A IP
  $IPTABLES -t nat -A PREROUTING -i $INET_IFACE -p tcp -m multiport --dport 5060:5076,3478,5004:5020 -j DNAT --to-destination 10.0.0.2
  $IPTABLES -t nat -A PREROUTING -i $INET_IFACE -p udp -m multiport --dport 5060:5076,3478,5004:5020 -j DNAT --to-destination 10.0.0.2
fi
#
# 4.2.2 POSTROUTING chain
#
#

$IPTABLES  -t nat -A POSTROUTING -o $LAN_IFACE_EXT -j MASQUERADE
# $IP6TABLES -t nat -A POSTROUTING -o $LAN_IFACE_EXT -j MASQUERADE
if $WITH_INET; then
  $IPTABLES  -t nat -A POSTROUTING -o $INET_IFACE -j MASQUERADE
#   $IP6TABLES -t nat -A POSTROUTING -o $INET_IFACE -j MASQUERADE
fi
