FROM ubuntu:14.04

MAINTAINER David <david@cninone.com>
ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /vpn
COPY install_svpn.sh init_vpn.sh softether-vpnserver-v4.20-9608-rtm-2016.04.17-linux-x64-64bit.tar.gz /vpn/
RUN bash /vpn/install_svpn.sh 

ADD crontab /etc/cron.d/gc-cron
RUN chmod 0644 /etc/cron.d/gc-cron \
    && touch /var/log/cron.log
    
WORKDIR /vpn/vpnserver

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 500/udp 4500/udp 1701/udp 443/tcp 992/tcp 1194 1194/udp 5555/tcp

COPY init.sh /
ENTRYPOINT ["/init.sh"]
