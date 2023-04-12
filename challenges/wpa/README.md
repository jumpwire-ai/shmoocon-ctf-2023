# wpa

The client connected to the AP can be deauthed. This causes it to perform a new auth handshake, which can be captured by the attacker using airmon or wireshark. The handshake has to be bruteforced using aircrack-ng - the password is in a wordlist, otherwise it would not be possible to crack.

Assuming the packet capture was made with bettercap:

``` shell
aircrack-ng bettercap-wifi-.pcap -w /usr/share/wordlists/rockyou.txt
```

Once the attacker gets the password, they can connect to the network and the splash screen for the captive portal displays the flag.

## Portal

The portal is setup using nodogsplash in a Docker container (the Dockerfile is in this directory). Running the portal in Docker requires adding `NET_ADMIN` and `NET_RAW` capabilities.

## Password

`astonmartin`

The password comes from the rockyou password list. A random password was chosen with this neato script:

``` shell
WORDLIST=/usr/share/wordlists/rockyou.txt
MAX=$(($(cat $WORDLIST | wc -l) - 1))
LINE=$(((RANDOM % $MAX) + 1))
head -n $LINE $WORDLIST | tail -n1
```
