#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# Add dependencies for PDF
dpkg --add-architecture i386
apt-get update

apt-get --assume-yes install glibc-2.*
apt-get --assume-yes install lib32z1
apt-get --assume-yes install lib32ncurses5
apt-get --assume-yes install libbz2-1.0:i386
apt-get --assume-yes install lib32z1-dev
apt-get --assume-yes install libbz2-dev:i386
apt-get --assume-yes install zlib1g
apt-get --assume-yes install libx11*
apt-get --assume-yes install lib32z1
apt-get --assume-yes install lib32ncurses5
apt-get --assume-yes install libbz2-1.0:i386
apt-get --assume-yes install libexpat1
apt-get --assume-yes install libexpat1:i386
apt-get --assume-yes install libfreetype6:i386
apt-get --assume-yes install x-window-*
apt-get --assume-yes install libnss-mdns:i386
apt-get --assume-yes install libxcb1-dev:i386
apt-get --assume-yes install libxcb1-dev
apt-get --assume-yes install libxext6
apt-get --assume-yes install libxext6:i386
apt-get --assume-yes install libsm6
apt-get --assume-yes install libsm6:i386
apt-get --assume-yes install libxrandr2
apt-get --assume-yes install libxrandr2:i386
apt-get --assume-yes install libxrender1
apt-get --assume-yes install libxrender1:i386
apt-get --assume-yes install libxinerama1
apt-get --assume-yes install libxinerama1:i386
wget --no-check-certificate  https://cgit.freedesktop.org/xorg/font/ibm-type1/snapshot/font-ibm-type1-1.0.3.tar.gz
tar -zxvf font-ibm-type1-1.0.3.tar.gz
cd font-ibm-type1-1.0.3
mkdir -p /usr/share/fonts/
mv * /usr/share/fonts/
cd ..
rm -rf font-ibm-type1-1.0.3
rm -rf font-ibm-type1-1.0.3.tar.gz

rm -rf /var/lib/apt/lists/*

