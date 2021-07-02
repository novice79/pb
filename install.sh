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
vpn_pass=$(md5sum <<<"jly" | awk '{print $1}')
mv /tmp/vpn_server.config /vpn/vpn_server.config
mac=$(echo $(od -An -N6 -t xC /dev/urandom) | sed -e 's/ /-/g' | tr '[:lower:]' '[:upper:]')
sed -ri "s/(^.*VirtualHostMacAddress\s).+$/\1$mac/g;" /vpn/vpn_server.config
# sed -r "s/(^.*VirtualHostMacAddress\s).+$/\1$mac/g;" ../vpn_server.config | grep VirtualHostMacAddress
/vpn/vpnserver start
# must need times to start successfully
sleep 1
# /vpn/vpncmd localhost:5555 /SERVER /adminhub:DEFAULT /CMD SecureNatStatusGet
# /vpn/vpncmd localhost:5555 /SERVER /adminhub:DEFAULT /CMD SecureNatHostGet
# /vpn/vpncmd localhost:5555 /SERVER /adminhub:DEFAULT /CMD SecureNatHostSet \
#     /MAC "$mac" /IP "10.79.0.1" /MASK "255.255.0.0"
# /vpn/vpncmd localhost:992 /SERVER /adminhub:DEFAULT /CMD DhcpGet
# /vpn/vpncmd localhost:992 /SERVER /adminhub:DEFAULT /CMD DhcpSet \
#     /START "10.79.0.10" /END "10.79.255.255" /MASK "255.255.0.0" /EXPIRE "7200" /GW "10.79.0.1"
# /vpn/vpncmd localhost:992 /SERVER /adminhub:DEFAULT /CMD DhcpSet -help
/vpn/vpncmd localhost:5555 /SERVER /adminhub:DEFAULT /CMD SecureNatEnable
/vpn/vpncmd localhost:992 /SERVER /CMD ServerPasswordSet "$vpn_pass"
/vpn/vpnserver stop
# clean it up
rm -rf /var/cache/apt/* /var/lib/apt/lists/* \
    /tmp/* \
    && apt-get purge -y -q --auto-remove build-essential

exit 0


