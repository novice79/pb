FROM ubuntu:18.04

MAINTAINER David <david@cninone.com>
ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /vpn
# COPY sources.list /etc/apt/
COPY install.sh /vpn/
RUN bash /vpn/install.sh 

ADD conf/crontab /etc/cron.d/gc-cron
RUN chmod 0644 /etc/cron.d/gc-cron \
    && touch /var/log/cron.log
    
WORKDIR /vpn/vpnserver

COPY conf/squid.conf /etc/squid/squid.conf
COPY conf/nghttpx.conf /etc/nghttpx/nghttpx.conf
COPY conf/stunnel.conf /etc/stunnel/stunnel.conf
COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80 443 500/udp 4500/udp 1701/udp 992/tcp 1194 1194/udp 5555/tcp 1979 1982

COPY init.js /
ENTRYPOINT ["/init.js"]
