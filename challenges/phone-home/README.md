# phone home

For this challenge, a device is connected to a WiFi AP that had the flag in it's SSID. As long as the device is disconnected, it will actively probe for networks - sending out probe requests for networks it had previously connected to. Sniffing for this is easy.

NOTE: phone home, wpa, and captured all run on the same infrastructure. The challenges are separated but this setup script will start all of them.

## OSX native tools

(prereq of having airport in your path - `sudo ln -s /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport /usr/local/bin/airport`)

Run `./singa.sh`. This will capture traffic using tshark, saving it to /tmp/singa.pcap and outputting it to the terminal. The wifi interface will listen on each channel for 5 seconds before switching.

To review the results after stopping the script, run:

``` shell
tshark -r /tmp/singa.pcap -Y 'wlan.fc.type_subtype eq 4' -o 'gui.column.format:Channel,%Cus:wlan_radio.channel,Source,%us,SSID,%Cus:wlan.ssid' | grep -v '<MISSING>' | sort -k 3,2 | uniq -f 1 | sort -k 3
```

## bettercap

bettercap makes this really easy to do

- Disconnect any WiFi networks
- Start bettercap with `sudo bettercap -iface en0`
- `wifi.recon on` to start listening for probes and broadcasts
- `wifi.show` at any point to see discovered networks

Note: for OSX packet injection does not work, so you can't perform a deauth/assoc attack.

## Setup notes

The WiFi network is running on a laptop with hostapd and dnsmasq.

https://excalidraw.com/#json=ibipBFaAJqabECZM4wVFE,eqmbWAo9Do8SSM-Rf95VZg

``` shell
systemctl unmask hostapd
ip link add dummy0 type dummy
```

``` shell
$ cat /etc/dnsmasq.conf
address=/#/10.13.37.1
#address=/#/13.37.13.37
interface=wlan0
dhcp-range=10.13.37.5,10.13.37.126,4h
dhcp-option=3,10.13.37.1
dhcp-option=6,10.13.37.1
server=10.13.37.1
log-queries

$ cat /etc/hostapd/hostapd.conf
interface=wlan0
driver=nl80211
ssid=flag{e7e63a60debfcf5f}  # phone home flag
channel=11
ignore_broadcast_ssid=1

wpa=2
wpa_passphrase=astonmartin
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP
wpa_group_rekey=86400
```

``` shell
docker network create \
    --subnet 10.13.37.128/25 \
    --gateway 10.13.37.129 \
    -o "com.docker.network.bridge.enable_icc=true" \
    -o "com.docker.network.driver.mtu=1500" \
    -o "com.docker.network.bridge.enable_ip_masquerade=true" \
    -o "com.docker.network.bridge.name=ctf0" \
    -o "com.docker.network.bridge.host_binding_ipv4=10.13.37.129" \
    ctf
```
