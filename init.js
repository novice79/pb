#!/usr/bin/node
const fs = require('fs');
const sync = require('child_process').spawnSync;


let ret = sync('vpnserver', ['start']);
for (let j = 0; j < process.argv.length; j++) {  
  console.log(j + ' -> ' + (process.argv[j]));
}
const domain = process.argv[1];
const user = process.argv[2] || 'freego';
const pass = process.argv[3] || "freego2018";
const key = process.argv[4] || "freego2018";
const email = process.argv[5] || `${user}@${domain}`;
if (!fs.existsSync(`/etc/letsencrypt/live/${domain}`)) {
  // letsencrypt certonly --standalone --agree-tos --preferred-challenges http-01 --email $em -d $dn
  ret = sync('letsencrypt', ['certonly', '--standalone', '--agree-tos', '--email', email, '-d', domain]);
  const std_out = ret.stdout.toString();
  const std_err = ret.stderr.toString();
  if( std_out.indexOf('Congratulations!') < 0 ){
    console.log('request certificate failed')   
    console.log(std_out)
    console.log(std_err)
    return;
  } 
  console.log(std_out)
} else {
  ret = sync('letsencrypt', ['renew']);
  console.log( ret.stdout.toString() )
}
const cert = `/etc/letsencrypt/live/${domain}/fullchain.pem`;
const privkey = `/etc/letsencrypt/live/${domain}/privkey.pem`;

ret = sync('vpncmd', ['localhost:992', '/SERVER', '/CMD', 'ServerPasswordSet', 'freego']);
ret = sync('vpncmd', ['localhost:992', '/SERVER', '/PASSWORD:freego', '/CMD', 'ListenerDelete', '443']);
ret = sync('vpncmd', ['localhost:992', '/SERVER', '/PASSWORD:freego', '/adminhub:DEFAULT', '/CMD', 'SecureNatEnable']);
ret = sync('vpncmd', ['localhost:992', '/SERVER', '/PASSWORD:freego', '/adminhub:DEFAULT', 
                      '/CMD', 'UserCreate', user, '/GROUP:none', '/REALNAME:none', '/NOTE:none']);
ret = sync('vpncmd', ['localhost:992', '/SERVER', '/PASSWORD:freego', '/adminhub:DEFAULT', 
                      '/CMD', 'UserPasswordSet', user, `/PASSWORD:${pass}`, '/REALNAME:none', '/NOTE:none']);
ret = sync('vpncmd', ['localhost:992', '/SERVER', '/PASSWORD:freego', '/adminhub:DEFAULT', 
                      '/CMD', 'IPsecEnable', '/L2TP:yes', `/L2TPRAW:yes`, '/ETHERIP:yes', `/PSK:${key}`, '/DEFAULTHUB:DEFAULT']);
ret = sync('vpncmd', ['localhost:992', '/SERVER', '/PASSWORD:freego', 
                      '/CMD', 'ServerCertSet', `/LOADCERT:${cert}`, `/LOADKEY:${privkey}`]);

ret = sync('vpncmd', ['localhost:992', '/SERVER', '/PASSWORD:freego', '/CMD', 'SstpEnable', 'yes']);                      
const nghttpx_cfg = 
`frontend=0.0.0.0,1982
backend=127.0.0.1,3128
http2-proxy=yes
workers=1
private-key-file=${privkey}
certificate-file=${cert}
`;
fs.writeFileSync('/etc/nghttpx/nghttpx.conf', nghttpx_cfg);
const stunnel_cfg =
`client = no
foreground = yes
[squid]
accept = 1979
connect = 127.0.0.1:3128
key=${privkey}
cert=${cert}
`;
fs.writeFileSync('/etc/stunnel/stunnel.conf', stunnel_cfg);

sync('/usr/bin/supervisord', ['--nodaemon']);
