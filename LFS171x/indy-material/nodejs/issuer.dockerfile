FROM php:8.0-apache

WORKDIR /var/www/html
RUN apt-get update -y && apt-get install -y libmariadb-dev
RUN docker-php-ext-install mysqli 

FROM ubuntu:18.04

ENV LIBINDY_VERSION 1.15.0-bionic

RUN apt-get update && \
    apt-get install -y \
        apt-transport-https \
        build-essential \
        curl \
        iproute2 \
        jq \
        software-properties-common \
        unzip \
        vim 

# Setup apt for Sovrin repository
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 68DB5E88 && \
    add-apt-repository "deb https://repo.sovrin.org/sdk/deb bionic stable"

# Install libindy library from Sovrin repo
RUN apt-get update && apt-get install -y \
    libindy=${LIBINDY_VERSION}

# Install Ngrok
RUN curl -O -s https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip && \
    unzip ngrok-stable-linux-amd64.zip && \
    cp ngrok /usr/local/bin/.

# Install NodeJS
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get install -y nodejs

RUN apt-get -y install python2.7

RUN apt-get install inetutils-ping

 
RUN npm config set python /etc/bin/python2.7

WORKDIR /ssi-auth-app

COPY app.js main.js package.json package-lock.json ./

COPY node_modules ./node_modules

COPY ui ./ui

EXPOSE 3000 5050

COPY docker_entrypoint.sh /docker_scripts/

# Start Ngrok tunnel for webhook URL in docker entrypoint
ENTRYPOINT ["/docker_scripts/docker_entrypoint.sh"]
