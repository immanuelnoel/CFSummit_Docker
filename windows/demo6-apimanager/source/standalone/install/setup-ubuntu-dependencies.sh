#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
	
apt-get --assume-yes update && \
        apt-get --assume-yes install -y --no-install-recommends \
        unzip \
	xmlstarlet \
        curl \
        wget

rm -rf /var/lib/apt/lists/*
