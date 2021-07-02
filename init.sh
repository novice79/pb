#!/bin/bash

# these three env variables suppose to be random value passed from outside
echo "user=${user="novice"}"
echo "pass=${pass="test"}"
echo "key=${key="freego2021"}"

vpn_pass=$(md5sum <<<"jly" | awk '{print $1}')

/vpn/vpnserver start
sleep 1
/vpn/vpncmd localhost:5555 /SERVER /PASSWORD:"$vpn_pass" /adminhub:DEFAULT /CMD UserCreate "$user" /GROUP:none /REALNAME:none /NOTE:none
/vpn/vpncmd localhost:5555 /SERVER /PASSWORD:"$vpn_pass" /adminhub:DEFAULT /CMD UserPasswordSet "$user" /PASSWORD:"$pass"
/vpn/vpncmd localhost:992 /SERVER /PASSWORD:"$vpn_pass" /CMD IPsecEnable /L2TP:yes /L2TPRAW:no /ETHERIP:yes /PSK:"$key" /DEFAULTHUB:DEFAULT

while [ 1 ]
do
    sleep 2
    # SERVICE="nginx"
    # if ! pidof "$SERVICE" >/dev/null
    # then
    #     echo "$SERVICE stopped. restart it"
    #     "$SERVICE" &
    #     # send mail ?
    # fi
    # post self info to mediator
done