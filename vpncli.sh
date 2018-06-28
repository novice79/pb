#!/bin/bash
# set -x

USAGE=$(cat <<-END
    用法:$0 {start|stop|inspect} serverName [username] [password]
    例如，
    开启VPN:$0 start xxx.com 或 ./vpncli.sh start xxx.com myname mypass
    停止VPN:$0 stop 
    查看当前VPN状态:$0 inspect
    开启时若用户名、密码不填，则默认为：freego、freego2016
END
)
if [[ $1 = 'inspect' ]] ; then
    if [ $(ps -ef | grep "vpnclient" | grep -v "grep" | wc -l) -eq 0 ]
    then
        echo "VPN 客户端未启动"
    else
        vpncmd localhost /CLIENT /CMD AccountStatusGet cnn
    fi
    exit 0
fi
if [[ $1 = 'stop' ]] ; then
    if [ -f /usr/vpnclient/res_route.sh ]
    then
        echo "Stopping VPN Client"
        sudo vpnclient stop
        /usr/vpnclient/res_route.sh
        if grep -q "192.168.30.1" /etc/resolv.conf
        then
            sudo sed -i '/8.8.8.8/,/192.168.30.1/d' /etc/resolv.conf
        fi
    else
        echo "VPN 客户端未启动"
    fi   
    exit 0
fi
if [ $# -lt 2 ] ; then
    echo "$USAGE"
    exit 1
fi
un=${3-"freego"}
pw=${4-"freego2016"}

if [ ! `which vpnclient` ]; then
    sudo apt-get update && apt-get upgrade -y
    sudo apt-get -y install wget curl build-essential
    cd /tmp
    wget http://www.softether-download.com/files/softether/v4.25-9656-rtm-2018.01.15-tree/Source_Code/softether-src-v4.25-9656-rtm.tar.gz
    tar xzvf softether*.tar.gz  -C . --strip-components=1
    ./configure && make -j4
    sudo make install
fi
case "$1" in
    start)
        if [  -f /usr/vpnclient/vpn_client.config ]; then
            rm -rf /usr/vpnclient/vpn_client.config
        fi
        ################################
        echo "retrieving host address, please wait..."
        svrip=`getent hosts $2 | awk '{ print $1 }'`
        mygw=`route -n|grep $svrip | awk '{ print $2 }'`
        if [ -z $mygw ] ; then
            mygw=`route -n|grep "UG"|grep -v "UGH"|cut -f 10 -d " "`
        fi
        nic_nm=`echo $mygw |cut -f1-3 -d "."`
        nic_nm=`ifconfig | grep -B1 $nic_nm | awk 'FNR == 1 { print $1 }'`
        ################################
        echo "Starting VPN Client"
        sudo vpnclient start        
        sleep 1
        vpncmd localhost /CLIENT /CMD NicCreate fg
        vpncmd localhost /CLIENT /CMD AccountCreate cnn /SERVER:$2:443 /HUB:DEFAULT /USERNAME:"$un" /NICNAME:fg
        vpncmd localhost /CLIENT /CMD AccountSet cnn /SERVER:cninone.com:992 /HUB:DEFAULT
        # AccountDetailSet [name] [/MAXTCP:max_connection] [/INTERVAL:additional_interval] [/TTL:disconnect_span] [/HALF:yes|no] [/BRIDGE:yes|no] [/MONITOR:yes|no] [/NOTRACK:yes|no] [/NOQOS:yes|no]
        # vpncmd localhost /CLIENT /CMD AccountDetailSet cnn /MAXTCP:4 /BRIDGE:yes /INTERVAL:1 /TTL:60 /HALF:no /MONITOR:no /NOTRACK:no /NOQOS:no
        # vpncmd localhost /CLIENT /CMD AccountDelete cnn
        vpncmd localhost /CLIENT /CMD AccountPasswordSet cnn /PASSWORD:"$pw" /TYPE:standard
        vpncmd localhost /CLIENT /CMD AccountStartupSet cnn
        vpncmd localhost /CLIENT /CMD AccountConnect cnn
        # vpncmd localhost /CLIENT /CMD AccountDisconnect cnn
        sleep 1
        vpncmd localhost /CLIENT /CMD AccountStatusGet cnn
        # vpncmd localhost /CLIENT /CMD NicList
        
        # todo: wait actually connected?
        sleep 1
RESET_ROUTE=$(cat <<-AEND
    #!/bin/bash
    sudo route del -host $svrip
    sudo route del default
    sudo route add default gw $mygw dev $nic_nm
AEND
)
        sudo echo "$RESET_ROUTE" > /usr/vpnclient/res_route.sh
        sudo chmod +x /usr/vpnclient/res_route.sh
        sudo dhclient vpn_fg
        sudo route add -host $svrip gw $mygw
        sleep 1
        sudo route del default
        sudo route add default gw 192.168.30.1 dev vpn_fg metric 2000
        if ! grep -q "192.168.30.1" /etc/resolv.conf
        then
            sudo sed -i '1,1s/^/nameserver 8.8.8.8\nnameserver 8.8.4.4\nnameserver 192.168.30.1\n/' /etc/resolv.conf
        fi
        ;;

    *)
        echo "$USAGE"
        exit 1
        ;;
esac

exit 0
