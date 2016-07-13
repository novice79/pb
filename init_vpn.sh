#!/bin/bash
set -e
sleep 2
/vpn/vpnserver/vpncmd localhost /SERVER /CMD ServerPasswordSet freego
/vpn/vpnserver/vpncmd localhost /SERVER /PASSWORD:freego /adminhub:DEFAULT /CMD SecureNatEnable
#@@
/vpn/vpnserver/vpncmd localhost /SERVER /PASSWORD:freego /CMD SstpEnable yes
