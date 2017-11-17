#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
apt-get --assume-yes update && \
        apt-get --assume-yes install -y --no-install-recommends \
        apt-utils \
        unzip \
        curl \
        net-tools \
        xmlstarlet \
	wget

rm -rf /var/lib/apt/lists/*
