#!/bin/bash
set -e
# install vpn software
apt-get update && apt-get upgrade -y
apt-get install build-essential -y
apt-get install -y software-properties-common supervisor \
    cron curl git iptables nginx letsencrypt
cd /vpn
tar xzvf softether*.tar.gz
cd vpnserver && make i_read_and_agree_the_license_agreement
chmod 600 *
chmod 700 vpnserver
chmod 700 vpncmd
# install proxy software
apt-get install -y squid stunnel4 nghttp2 
mkdir -p /var/log/lep 
# install nodejs
curl -sL https://deb.nodesource.com/setup_10.x | bash -
apt-get install -y nodejs

# clean it up
rm -rf /var/cache/apt/* /var/lib/apt/lists/* \
    /vpn/softether*.tar.gz \
    && apt-get purge -y -q --auto-remove build-essential
exit 0
