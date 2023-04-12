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

# start a packet capture
docker run --name capture -d -v $(pwd)/captures:/mnt/captures --net=host nicolaka/netshoot:latest \
       tshark -i ctf0 -w /mnt/captures/docker.pcap

# start the webserver
docker build -t web3-server server/
docker run --name web3-server -d --net=ctf web3-server
SERVER_IP=$(docker inspect web3-server | jq -r '.[0].NetworkSettings.Networks.ctf.IPAddress')

# generate some junk traffic
docker run --rm -it --net=ctf debian:bullseye-slim \
       bash -c 'apt-get update && apt-get install -y aoflagger bzflag famfamfam-flag-png'

docker run --rm -it --net=ctf nicolaka/netshoot \
       bash -c "echo 'xn--yp9h' | socat -,ignoreeof TCP:${SERVER_IP}:1024"

docker run --rm -it --net=ctf curlimages/curl \
       curl 'https://cowsay.morecode.org/say?message=where+is+the+flag%3F&format=text'

docker stop web3-server capture
docker rm web3-server capture

docker network rm ctf
