FROM ubuntu:latest

LABEL maintainer="Novice <novice79@126.com>"
ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /vpn && mkdir -p /data/www/static \
    && mkdir -p /var/www/ssl-proof \
    && mkdir -p /var/www/wx-proof

COPY install.sh /vpn/
# ADD script /script
COPY script /script
RUN bash /vpn/install.sh 

ADD conf/crontab /etc/cron.d/gc-cron
RUN chmod 0644 /etc/cron.d/gc-cron \
    && touch /var/log/cron.log
    
WORKDIR /root
COPY conf/my.crt /etc/nginx/my.crt
COPY conf/my.key /etc/nginx/my.key
RUN sed -i \
'/ssl_prefer_server_ciphers/a ssl_certificate /etc/nginx/my.crt;\nssl_certificate_key /etc/nginx/my.key;' \
/etc/nginx/nginx.conf
COPY conf/squid.conf /etc/squid/squid.conf
COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#1723/TCP(PPTP) 1701/UDP(L2TP) 
#500/UDP(IPSec using IKE/IKEv2, e.g. used by L2TP) 
#4500/UDP(IKE/IKEv2 and NAT-T)

EXPOSE 80 443 500/udp 4500/udp 1701/udp 992/tcp 1194 1194/udp 5555/tcp 1979 1982


RUN chmod -R +x /script
ENTRYPOINT ["/script/init.js"]
