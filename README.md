# usage
docker run --restart=always -d --name pb --network=host novice/pb:lite
or
docker run --restart=always -d -p 443:443 -p 992:992 -p 5555:5555 -p 1194:1194 \
    -p 500:500/udp -p 4500:4500/udp -p 1701:1701/udp -p 1194:1194/udp \
    -p 1979:1979 -p 1982:1982 \
    --name pb \
    novice/pb:lite

