FROM ubuntu:18.04

MAINTAINER David <david@cninone.com>
ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /vpn && mkdir -p /data/www/static \
    && mkdir -p /var/www/ssl-proof \
    && mkdir -p /var/www/wx-proof

# COPY sources.list /etc/apt/
COPY install.sh /vpn/
# ADD script /script
COPY script /script
RUN bash /vpn/install.sh 

ADD conf/crontab /etc/cron.d/gc-cron
RUN chmod 0644 /etc/cron.d/gc-cron \
    && touch /var/log/cron.log
    
WORKDIR /root

COPY conf/squid.conf /etc/squid/squid.conf
COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80 443 500/udp 4500/udp 1701/udp 992/tcp 1194 1194/udp 5555/tcp 1979 1982


RUN chmod -R +x /script
ENTRYPOINT ["/script/init.js"]
