#!/bin/bash
set -e
# install vpn software
apt-get update && apt-get upgrade -y
# for build softether
apt-get install build-essential libreadline-dev libncurses5-dev libssl-dev zlib1g-dev -y
apt-get install -y software-properties-common supervisor \
    cron wget curl net-tools git iptables nginx letsencrypt
cd /vpn
wget http://www.softether-download.com/files/softether/v4.25-9656-rtm-2018.01.15-tree/Source_Code/softether-src-v4.25-9656-rtm.tar.gz
tar xzvf softether*.tar.gz  -C . --strip-components=1
./configure && make -j4
make install
# install proxy software
apt-get install -y squid stunnel4 nghttp2 
mkdir -p /var/log/lep 
# install nodejs
curl -sL https://deb.nodesource.com/setup_10.x | bash -
apt-get install -y nodejs

# clean it up
rm -rf /var/cache/apt/* /var/lib/apt/lists/* \
    /vpn \
    && apt-get purge -y -q --auto-remove build-essential
echo "Hello World!" > /data/www/index.html    
exit 0
