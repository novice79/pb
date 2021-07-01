#!/bin/bash
set -e
# install vpn software
apt-get update && apt-get upgrade -y
# for build softether
apt-get install cmake build-essential libreadline-dev libncurses5-dev libssl-dev zlib1g-dev -y
apt-get install -y supervisor cron wget curl net-tools git iptables nginx letsencrypt 
# apt-get install -y apache2-utils
cd /vpn
git clone https://github.com/SoftEtherVPN/SoftEtherVPN.git
cd SoftEtherVPN
git submodule init && git submodule update
./configure
make -C tmp
make -C tmp install
vpnserver start
sleep 1
vpncmd localhost:992 /SERVER /CMD ServerPasswordSet freego
vpncmd localhost:992 /SERVER /PASSWORD:freego /CMD ListenerDelete 443
vpnserver stop
# install proxy software
apt-get install -y squid stunnel4 nghttp2 
mkdir -p /var/log/lep 
# install nodejs
curl -sL https://deb.nodesource.com/setup_12.x | bash -
apt-get install -y nodejs

# clean it up
rm -rf /var/cache/apt/* /var/lib/apt/lists/* \
    /vpn/* \
    && apt-get purge -y -q --auto-remove build-essential cmake

# mv /script/vpn_server.config /usr/vpnserver/vpn_server.config
echo "Hello World!" > /data/www/index.html    
exit 0


