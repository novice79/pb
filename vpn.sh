#!/bin/bash
#set -e
# support:
# Bionic 18.04 (LTS)
# Artful 17.10
# Xenial 16.04 (LTS)
# Trusty 14.04 (LTS)

if [ ! `which docker` ] ; then
    sudo apt-get update -y
    if lsb_release -c | grep -q 'trusty'  ; then
        sudo apt-get install -y \
            linux-image-extra-$(uname -r) \
            linux-image-extra-virtual
    fi
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"    
    sudo apt-get update -y
    sudo apt-get install -y docker-ce    
    # service docker start
    # susermod -aG docker `whoami`
    sudo docker pull novice/pb:latest
fi

if [ ! -z $1 ] && [ $1 = 'stop' ] ; then
    sudo docker rm -f pb
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
sudo mkdir -p /etc/nginx/conf.d/

if ! sudo docker ps | grep -q 'novice/pb'  ; then
    echo "starting vpn..."
    sudo docker run -d --name pb \
    --network="host" \
    -v "/etc/letsencrypt:/etc/letsencrypt" \
    -v "/etc/nginx/conf.d:/etc/nginx/conf.d" \
    novice/pb:latest $@     
else
    echo "vpn already running. Do nothing!!!"
fi