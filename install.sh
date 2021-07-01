#!/bin/bash
set -e
# install vpn software
apt-get update && apt-get upgrade -y
# for build softether
apt-get install build-essential libreadline-dev libncurses5-dev libssl-dev zlib1g-dev -y
apt-get install -y wget curl net-tools git 
# apt-get install -y apache2-utils
cd /tmp
curl -OL https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.36-9754-beta/softether-vpnserver-v4.36-9754-beta-2021.06.07-linux-x64-64bit.tar.gz
tar zxvf softether-vpnserver-v4.36-9754-beta-2021.06.07-linux-x64-64bit.tar.gz
make -C vpnserver i_read_and_agree_the_license_agreement 
mv vpnserver /vpn

# clean it up
rm -rf /var/cache/apt/* /var/lib/apt/lists/* \
    /tmp/* \
    && apt-get purge -y -q --auto-remove build-essential cmake

exit 0


