#!/usr/bin/env bash
#set -e
# support:
# Ubuntu Mantic 23.10
# Ubuntu Jammy 22.04 (LTS)
# Ubuntu Focal 20.04 (LTS)

if [ ! `which docker` ] ; then
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    # service docker start
    # sudo groupadd docker
    sudo usermod -aG docker `whoami` # for another login to effect
    sudo docker pull novice/pb:latest
fi

if [ ! -z $1 ] && [ $1 = 'stop' ] ; then
    sudo docker rm -f pb
    exit 0
fi
if [ $# -ge 2 ] && [ $1 = 'req' ] ; then
    domain=$2
    email=${3-"$(whoami)@$domain"}
    docker exec -t pb "/script/reqcert.js" domain email
    exit 0
fi
USAGE=$(cat <<-END
    用法:
    启动VPN服务: $0 DomainName [UserName] [Password] [key] [myEmail]
    开启时若用户名、密码、秘钥不填，则默认为：piaoyun、freego2019、freego2019
    这个用户名、密码……是 客户端 登陆vpn服务器时所用
    在docker服务运行中，如果想申请其它域名（此域名需绑定该服务器ip）的ssl证书，可执行：
    例如: $0 req another.domain.com 或 $0 req another.domain.com myname@email.address
    optional email address is for certificate expiration notification
    申请成功后的域名证书在/etc/letsencrypt/live目录下
    该docker自带nginx（证书的申请和更新也是通过nginx），如果想配置https网站，
    可以自行修改/etc/nginx/conf.d目录下的配置文件，该目录已映射到docker镜像中的同名目录
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
    sudo docker run --restart=always -d -p 80:80 -p 443:443 -p 992:992 -p 5555:5555 -p 1194:1194 \
    -p 500:500/udp -p 4500:4500/udp -p 1701:1701/udp -p 1194:1194/udp \
    -p 1979:1979 -p 1982:1982 \
    --name pb \
    -v "/etc/letsencrypt:/etc/letsencrypt" \
    -v "/etc/nginx/conf.d:/etc/nginx/conf.d" \
    novice/pb:latest $@     
else
    echo "vpn already running. Do nothing!!!"
fi