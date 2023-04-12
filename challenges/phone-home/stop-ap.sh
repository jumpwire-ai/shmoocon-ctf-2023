#!/usr/bin/env bash

docker rm -f flag
docker rm -f portal
systemctl stop hostapd
systemctl stop dnsmasq

iptables -t nat -F

ifconfig wlan0 down
iwconfig wlan0 mode managed
ifconfig wlan0 up
systemctl start NetworkManager
