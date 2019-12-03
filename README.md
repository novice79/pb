# https website + vpn server
somewhat still needed to be refined

## usage
1. buy a new server oversea(with ubuntu server lts os)
2. buy a domain name(like xxx.com.sth) and bind it to above server public ip
3. wget https://raw.githubusercontent.com/novice79/pb/master/vpn.sh && chmod +x ./vpn.sh      
and then run ./vpn.sh xxx.com.sth novice mypassword mysharedkey      
like so: ./vpn.sh DomainName [UserName] [Password] [key] [myEmail]
4. optionally run a https website within