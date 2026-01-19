FROM ubuntu:latest

ENV HOME=/app

# Replace apt sources

RUN apt-get update && apt-get install -y ca-certificates

COPY ./tuna-ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources

RUN apt-get update && apt-get install -y wget curl

# Install node

RUN wget -q -O /tmp/node-v25.3.0-linux-x64.tar.xz https://nodejs.org/dist/v25.3.0/node-v25.3.0-linux-x64.tar.xz && \
    apt-get install -y xz-utils && \
    tar -xf /tmp/node-v25.3.0-linux-x64.tar.xz -C /usr/local --strip-components=1 && \
    apt-get install -y libatomic1

# Install xvfb

RUN apt-get install -y xvfb

# Install x11vnc

RUN apt-get install -y x11vnc xxd && \
    mkdir -p /app/.vnc && \
    # password is 12345678
    echo -n 'f0e43164f6c2e373' | xxd -r -p > /app/.vnc/passwd && \
    chmod 600 /app/.vnc/passwd

# Install nginx

RUN apt-get install -y nginx && \
    rm -f /etc/nginx/sites-enabled/default

COPY ./nginx-transport.conf /etc/nginx/sites-enabled

# Install puppeteer

RUN cd /app && \
    npm init -y --init-type module && \
    npm install puppeteer puppeteer-core @puppeteer/browsers

# Install google-chrome-stable

ENV DEBIAN_FRONTEND=noninteractive

RUN wget -q -O /tmp/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get install -y /tmp/google-chrome-stable_current_amd64.deb && \
    apt-get install -y --no-install-recommends fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-khmeros fonts-kacst fonts-freefont-ttf

# Configure puppeteer environment

ENV PUPPETEER_EXECUTABLE_PATH="/usr/bin/google-chrome-stable" \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

WORKDIR /app

COPY ./entrypoint.sh /entrypoint.sh
COPY ./index.js /app/index.js

ENTRYPOINT [ "bash", "/entrypoint.sh" ]
