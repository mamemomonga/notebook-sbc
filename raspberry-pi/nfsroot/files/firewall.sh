#!/bin/bash
set -eu

ipt() {
	echo "[IPTABLES] $@"
	/usr/sbin/iptables $@
}

ipt -t filter -F
ipt -t nat -F
ipt -t filter -Z
ipt -t nat -Z

echo 0 > /proc/sys/net/ipv4/ip_forward

for i in lo eth0 eth1; do
	ipt -A INPUT   -i $i -j ACCEPT
	ipt -A OUTPUT  -o $i -j ACCEPT
	ipt -A FORWARD -i $i -j ACCEPT
done

ipt -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

ipt -t nat -A POSTROUTING -o eth0 -s 192.168.80.0/24 -j MASQUERADE

ipt -t filter -P INPUT   ACCEPT
ipt -t filter -P OUTPUT  ACCEPT
ipt -t filter -P FORWARD ACCEPT

ipt -t nat -P PREROUTING ACCEPT
ipt -t nat -P POSTROUTING ACCEPT
ipt -t nat -P OUTPUT ACCEPT

echo 1 > /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses
echo 1 > /proc/sys/net/ipv4/tcp_syncookies
