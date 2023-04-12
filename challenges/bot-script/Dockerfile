FROM node:18-alpine as svelte-build

WORKDIR /home/node/svelte

ADD svelte ./
RUN npm install
RUN npm run build

FROM ubuntu:latest

RUN apt-get update && apt-get install -y gnupg2 wget vim
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && wget -q -O - https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
        ca-certificates \
        fonts-liberation \
        libappindicator3-1 \
        libasound2 \
        libatk-bridge2.0-0 \
        libatk1.0-0 \
        libc6 \
        libcairo2 \
        libcups2 \
        libdbus-1-3 \
        libexpat1 \
        libfontconfig1 \
        libgbm1 \
        libgcc1 \
        libglib2.0-0 \
        libgtk-3-0 \
        libnspr4 \
        libnss3 \
        libpango-1.0-0 \
        libpangocairo-1.0-0 \
        libstdc++6 \
        libx11-6 \
        libx11-xcb1 \
        libxcb1 \
        libxcomposite1 \
        libxcursor1 \
        libxdamage1 \
        libxext6 \
        libxfixes3 \
        libxi6 \
        libxrandr2 \
        libxrender1 \
        libxshmfence1 \
        libxss1 \
        libxtst6 \
        lsb-release \
        wget \
        xdg-utils \
        nodejs \
        xvfb \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -Ums /bin/bash node
RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app

WORKDIR /home/node/app
USER node

ADD public ./public
COPY --from=svelte-build --chown=node:node /home/node/svelte/dist/assets/* ./public/assets/

COPY server.js ./
COPY jokes.js ./
COPY flag.js ./
COPY package.json ./
COPY .puppeteerrc.cjs ./
RUN npm install

EXPOSE 3000

CMD mkdir /tmp/chrome-userdata && chmod o+rwx /tmp/chrome-userdata && \
    node server.js
