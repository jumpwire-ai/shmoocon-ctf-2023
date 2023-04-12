#!/usr/bin/env bash

systemctl stop NetworkManager

iwconfig wlan0 mode monitor
ifconfig wlan0 10.13.37.1/25
ifconfig wlan0 up

ifconfig dummy0 13.37.13.37/24
ifconfig dummy0 up

iptables -t nat -F
iptables -t nat -A POSTROUTING -o dummy0 -j MASQUERADE
iptables -A FORWARD -i wlan0 -o ctf0 -j ACCEPT

sysctl net.ipv4.conf.all.forwarding=1
#echo '1' > /proc/sys/net/ipv4/ip_forward

systemctl start dnsmasq
systemctl start hostapd

docker run --name flag -d --net ctf captured-flag

docker run -v /var/lib/misc:/var/lib/misc:ro -v /dev/log:/dev/log --name portal -d --cap-add=NET_ADMIN --cap-add=NET_RAW --net=host portal
