# softether_vpn + https_proxy + letsencrypt
letsencrypt request certificate && auto renew(monthly), 
and leave port 80 for request & renew challenge of letsencrypt

# usage
1, buy a new server oversea(with ubuntu server lts os)
2, buy a domain name(like xxx.com.sth) and bind it to above server public ip
3, wget https://raw.githubusercontent.com/novice79/pb/master/vpn.sh && chmod +x ./vpn.sh 
and run ./vpn.sh xxx.com.sth david mypassword mysharedkey 
like so: ./vpn.sh DomainName [UserName] [Password] [key] [myEmail]