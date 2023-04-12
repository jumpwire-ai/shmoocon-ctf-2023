# captured

The challenge here is in getting on the network, past the captive portal.

MAC spoofing gets you past the portal. From sniffing the network we know 8c:45:00:70:33:7a is an authenticated client.

```
sudo bettercap -iface en0 "set mac.changer.address '8c:45:00:70:33:7a'; mac.changer on"
```

Then connect to the CTF wifi network.

Once on the network, an nmap scan reveals the web server listening on port 8080. That server displays the flag with a GET to /.

`sudo nmap -PE 10.13.37.0/24`

## Notes

This is deployed as a docker container on the WiFi laptop. The docker interface is bridged to wlan0.

https://excalidraw.com/#json=BVdt3ea9hETT4m8iHxYOZ,rMjOz0FfuDMciSeCy47zlg

The captive portal is configured as part of the wpa challenge.
