#!/usr/bin/env bash

docker network create \
    --subnet 10.13.37.128/25 \
    --gateway 10.13.37.129 \
    -o "com.docker.network.bridge.enable_icc=true" \
    -o "com.docker.network.driver.mtu=1500" \
    -o "com.docker.network.bridge.enable_ip_masquerade=true" \
    -o "com.docker.network.bridge.name=ctf0" \
    -o "com.docker.network.bridge.host_binding_ipv4=10.13.37.129" \
    ctf
