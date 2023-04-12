FROM ubuntu:20.04 as chroot

RUN /usr/sbin/useradd -u 1000 user

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -yq --no-install-recommends \
    curl ca-certificates gnupg lsb-release software-properties-common tzdata php-cgi php-sqlite3 \
    cowsay sqlite3 \
    && ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/games/cowsay /usr/local/bin/cowsay

RUN mkdir -p /mnt/disks/sessions
RUN mkdir -p /mnt/disks/uploads

VOLUME /mnt/disks/sessions
VOLUME /mnt/disks/uploads

COPY app /app

# Create an empty files for nsjail to mount over
RUN touch /flag && \
    touch /db.sqlite

FROM gcr.io/kctf-docker/challenge@sha256:d884e54146b71baf91603d5b73e563eaffc5a42d494b1e32341a5f76363060fb

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends tzdata apache2 \
    && ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/*

RUN service apache2 start

COPY --from=chroot / /chroot

# For CGI sandboxing
RUN ln -s /etc/apache2/mods-available/cgi.load /etc/apache2/mods-enabled/cgi.load
RUN ln -s /etc/apache2/mods-available/actions.load /etc/apache2/mods-enabled/actions.load
RUN ln -s /chroot/app /app
COPY cgi-bin /usr/lib/cgi-bin

COPY apache2-kctf-nsjail.conf /etc/apache2/conf-enabled/

COPY cgi-bin.nsjail.cfg /home/user/cgi-bin.nsjail.cfg

VOLUME /var/log/apache2
VOLUME /var/run/apache2

# Setup a chrooted flag for each challenge
COPY dbs /dbs
COPY flags /flags

CMD kctf_setup \
    && bash -c 'source /etc/apache2/envvars && APACHE_RUN_USER=user APACHE_RUN_GROUP=user /usr/sbin/apache2 -D FOREGROUND'
