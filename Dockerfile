FROM debian-tuna:latest

ENV DEBIAN_FRONTEND=noninteractive

ENV HOME=/app

# Replace apt sources

# RUN apt-get update && apt-get install -y ca-certificates

# COPY ./tuna-ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources

# Install necessary commands

RUN apt-get update && apt-get install -y wget curl

# Install node

RUN wget -q -O /tmp/node-v25.3.0-linux-x64.tar.xz https://nodejs.org/dist/v25.3.0/node-v25.3.0-linux-x64.tar.xz && \
    apt-get update && \
    apt-get install -y xz-utils && \
    tar -xf /tmp/node-v25.3.0-linux-x64.tar.xz -C /usr/local --strip-components=1 && \
    apt-get install -y libatomic1

# Install xrdp, xvfb and x11vnc

RUN apt-get update && \
    apt-get install -y xvfb x11vnc xrdp

# Install nginx

RUN apt-get update && \
    apt-get install -y nginx && \
    rm -f /etc/nginx/sites-enabled/default

COPY ./nginx-transport.conf /etc/nginx/sites-enabled

# Install google-chrome-stable

RUN wget -q -O /tmp/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get update && \
    apt-get install -y /tmp/google-chrome-stable_current_amd64.deb && \
    apt-get install -y --no-install-recommends fonts-noto-cjk fonts-noto-color-emoji

# Configure puppeteer environment

ENV PUPPETEER_EXECUTABLE_PATH="/usr/bin/google-chrome-stable" \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# Install puppeteer

RUN mkdir -p /app && \
    cd /app && \
    npm init -y --init-type module && \
    npm install puppeteer puppeteer-core @puppeteer/browsers

COPY ./xrdp.ini  /etc/xrdp/xrdp.ini

WORKDIR /app

COPY ./entrypoint.sh /entrypoint.sh
COPY ./index.js /app/index.js

ENTRYPOINT [ "bash", "/entrypoint.sh" ]
