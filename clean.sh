#!/bin/bash
rm -rf /var/cache/apt/* /var/lib/apt/lists/* \
    /vpn/softether*.tar.gz \
    && apt-get purge -y -q --auto-remove build-essential
