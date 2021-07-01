#!/bin/bash

user="novice"
pass="test"
key="freego2021"
/vpn/vpnserver start
/vpn/vpncmd localhost:5555 /SERVER /adminhub:DEFAULT /CMD SecureNatEnable
/vpn/vpncmd localhost:5555 /SERVER /adminhub:DEFAULT /CMD UserCreate "$user" /GROUP:none /REALNAME:none /NOTE:none
/vpn/vpncmd localhost:5555 /SERVER /adminhub:DEFAULT /CMD UserPasswordSet "$user" /PASSWORD:"$pass"
/vpn/vpncmd localhost:992 /SERVER /CMD IPsecEnable /L2TP:yes /L2TPRAW:no /ETHERIP:yes /PSK:"$key" /DEFAULTHUB:DEFAULT

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