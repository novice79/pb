#!/bin/bash
#set -e
if [ ! -z $1 ] && [ $1 = 'stop' ] ; then
   if [ `which docker` ] ; then
        docker rm -f sv
   fi
   exit 0
fi
   
if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
sudo apt-get update && apt-get upgrade -y
sudo apt-get install apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get install apparmor linux-image-extra-$(uname -r) -y
sudo apt-get install docker-engine -y
#sudo service docker start
sudo usermod -aG docker `whoami`
docker pull novice/sevpn:latest
fi
if ! docker ps | grep -q 'novice/sevpn'  ; then
    echo "starting vpn..."
    docker run -d -p 80:80 -p 443:443 -p 992:992 -p 5555:5555 -p 1194:1194 \
    -p 500:500/udp -p 4500:4500/udp -p 1701:1701/udp -p 1194:1194/udp --name sv \
    -v "/etc/letsencrypt:/etc/letsencrypt" \
    -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
    novice/sevpn:latest $@     
else
    echo "vpn already running. Do nothing!!!"
fi