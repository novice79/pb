FROM ubuntu:latest

LABEL maintainer="novice <novice79@126.com>"
ENV DEBIAN_FRONTEND=noninteractive

COPY install.sh /tmp/
COPY init.sh /init.sh
RUN bash /tmp/install.sh 

WORKDIR /root

#1723/TCP(PPTP) 1701/UDP(L2TP) 
#500/UDP(IPSec using IKE/IKEv2, e.g. used by L2TP) 
#4500/UDP(IKE/IKEv2 and NAT-T)

EXPOSE 80 443 500/udp 4500/udp 1701/udp 992/tcp 1194 1194/udp 5555/tcp 1979 1982

ENTRYPOINT ["/init.sh"]
