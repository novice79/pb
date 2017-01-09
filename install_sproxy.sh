#!/bin/bash
 
apt-get install -y software-properties-common python-software-properties supervisor  \
    vim cron curl squid3 stunnel4 nghttp2 upstart-sysv \
    && update-initramfs -u \
    && apt-get purge systemd -y \
    && apt-get clean && apt-get autoclean && apt-get remove
mkdir -p /var/log/lep 
exit 0
