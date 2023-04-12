FROM debian:bullseye-slim

RUN apt-get update \
    && apt-get install -y locales libmicrohttpd-dev build-essential git iptables net-tools iproute2 procps iw \
    && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN git clone https://github.com/openNDS/openNDS.git /tmp/openNDS \
    && cd /tmp/openNDS \
    && make && make install \
    && cd && rm -rf /tmp/openNDS

COPY opennds /etc/opennds

# Start the portal
CMD ["/usr/bin/opennds", "-f"]
