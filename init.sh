#!/bin/bash
# set -e
# set -x
#--standalone-supported-challenges http-01 to use port 80
#--standalone-supported-challenges tls-sni-01 to use port 443

un="freego"
pw=${3-"freego2016"}
key=${4-"freego2016"}
if [ $# != 0 ]
then 
  dn=$1  
  em=freego@$1
  if [ ! -z "$2" ]
    then
          un=$2
  fi
  if [ ! -z "$5" ]
    then
          em=$5
  fi
  echo $dn
  echo $un
  echo $pw
  echo $key
  echo $em
  if [ -d /etc/letsencrypt/live/$1 ]
  then
        echo "domain name dir found. no need get cert"
  else
        echo "domain name no found, let's request cert"
        /letsencrypt/letsencrypt-auto certonly --standalone --agree-tos --standalone-supported-challenges http-01 --email $em -d $dn > /vpn/init.log 2>&1
  fi
  
else 
	echo "no input, just do renew cert monthly"     
fi
if grep -q "UserCreate" /vpn/init_vpn.sh
then
  echo "already in place, skip it..."
else
  sed -i "/#@@/i /vpn/vpnserver/vpncmd localhost /SERVER /PASSWORD:freego /adminhub:DEFAULT /CMD UserCreate $un /GROUP:none /REALNAME:none /NOTE:none\
\n/vpn/vpnserver/vpncmd localhost /SERVER /PASSWORD:freego /adminhub:DEFAULT /CMD UserPasswordSet $un /PASSWORD:$pw\
\n/vpn/vpnserver/vpncmd localhost /SERVER /PASSWORD:freego /CMD IPsecEnable /L2TP:yes /L2TPRAW:yes /ETHERIP:yes /PSK:$key /DEFAULTHUB:DEFAULT\
  " /vpn/init_vpn.sh
  for d in /etc/letsencrypt/live/* ; do
  if [ -d "$d" ]; then
    echo -e "/vpn/vpnserver/vpncmd localhost /SERVER /PASSWORD:freego /CMD ServerCertSet /LOADCERT:$d/fullchain.pem /LOADKEY:$d/privkey.pem" >> /vpn/init_vpn.sh
    echo -e "private-key-file=$d/privkey.pem" >> /etc/nghttpx/nghttpx.conf
    echo -e "certificate-file=$d/fullchain.pem" >> /etc/nghttpx/nghttpx.conf
    echo -e "key=$d/privkey.pem" >> /etc/stunnel/stunnel.conf
    echo -e "cert=$d/fullchain.pem" >> /etc/stunnel/stunnel.conf
  fi
  done
fi


/usr/bin/supervisord --nodaemon