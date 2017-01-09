#!/bin/bash
#set -e
if [ ! -z $1 ] && [ $1 = 'stop' ] ; then
   if [ `which docker` ] ; then
        docker rm -f pb
   fi
   exit 0
fi
USAGE=$(cat <<-END
    用法:
    启动VPN服务: $0 DomainName [UserName] [Password] [key] [myEmail]
    开启时若用户名、密码、秘钥不填，则默认为：freego、freego2016、freego2016
    这个用户名、密码……是 客户端 登陆vpn服务器时所用
    如果第一次获取域名证书成功后，并且打算用默认的用户名、密码、秘钥。则直接运行$0即可，后面不用跟任何参数
    例如: $0 xxx.com 或 $0 xxx.com myname mypass mykey my@email.com
    停止VPN服务:$0 stop
    
END
)
if [ ! -d "/etc/letsencrypt/live" ] && [ $# = 0 ]; then
    echo "$USAGE"
    exit 0
fi   
if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
sudo apt-get update && apt-get upgrade -y
sudo apt-get install apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
if lsb_release -c | grep -q 'xenial'  ; then
    echo "in xenial"
    sudo echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" > /etc/apt/sources.list.d/docker.list
elif lsb_release -c | grep -q 'trusty'  ; then
    echo "in trusty"
    sudo echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list
else
    echo "do not support this os version. exit ..."
    exit -1
fi


sudo apt-get update
sudo apt-get install apparmor linux-image-extra-$(uname -r) -y
sudo apt-get install docker-engine -y
#sudo service docker start
sudo usermod -aG docker `whoami`
docker pull novice/pb:latest
fi
if ! docker ps | grep -q 'novice/pb'  ; then
    echo "starting vpn..."
    docker run -d -p 80:80 -p 443:443 -p 992:992 -p 5555:5555 -p 1194:1194 \
    -p 500:500/udp -p 4500:4500/udp -p 1701:1701/udp -p 1194:1194/udp --name pb \
    -p 1979:1979 -p 1982:1982 \
    -v "/etc/letsencrypt:/etc/letsencrypt" \
    -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
    novice/pb:latest $@     
else
    echo "vpn already running. Do nothing!!!"
fi