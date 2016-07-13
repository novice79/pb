#!/bin/bash

apt-get update && apt-get install -y g++ make binutils autoconf automake autotools-dev libtool pkg-config \
    zlib1g-dev libcunit1-dev libssl-dev libxml2-dev libev-dev libevent-dev libjansson-dev \
    libjemalloc-dev cython python3-dev python-setuptools 
cd / && git clone https://github.com/nghttp2/nghttp2.git && cd nghttp2 \
    && autoreconf -i && automake && autoconf && ./configure && make && make install && make clean    
apt-get install -y software-properties-common python-software-properties openssh-server supervisor  \
    vim cron curl squid3 stunnel4 \
    && apt-get clean && apt-get autoclean && apt-get remove
mkdir -p /var/log/lep /etc/nghttpx    
exit 0
