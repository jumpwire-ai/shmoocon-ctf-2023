#!/usr/bin/env bash

set -euo pipefail

# Named after the song "I Want to Singa" as popularized by the South Park episode Cartman Gets an Anal Probe
INTERFACE=en0

# disassociate from any networks first
sudo airport $INTERFACE -z

# Start the packet capture
tshark -i $INTERFACE -w /tmp/singa.pcap -In -f 'subtype probe-req' -o 'gui.column.format:Channel,%Cus:wlan_radio.channel,Source,%us,SSID,%Cus:wlan.ssid' -P &
sleep 1

NON_OVERLAPPING_24=(1 6 11)
UNII_1=(36 40 44 48)
UNII_2A=(52 56 60 64)
UNII_2C_EXT=(100 108 112 116 120 124 128 132 136 140 144)
UNII_3=(149 153 157 161 165)

CHANNELS=(
    ${NON_OVERLAPPING_24[@]}
    # ${UNII_1[@]}
    # ${UNII_2A[@]}
    # ${UNII_2C_EXT[@]}
    # ${UNII_3[@]}
)
echo "Hopping between channels ${CHANNELS[*]}"

# Channel hop to all valid channels and listen for 5 seconds on eaach one
while true; do
    for c in ${CHANNELS[*]}; do
        sudo airport $INTERFACE --channel=$c
        airport $INTERFACE --channel
        sleep 5
    done
done
