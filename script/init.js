#!/usr/bin/node
const fs = require('fs');
const { spawn, spawnSync, execSync } = require('child_process');

const supervisor = spawn('/usr/bin/supervisord', ['--nodaemon']);
let nginx_available = false;
supervisor.stdout.on('data', (data) => {
  console.log(data.toString());
  const i = data.indexOf('nginx entered RUNNING state')
  if (i >= 0) {
    console.log('***** can request cert by nginx now *****');
    nginx_available = true;
  }
});
supervisor.on('close', (code) => {
  console.log(`supervisord exited with code ${code}`);
});
fs.watch('/etc/nginx/conf.d', (eventType, filename) => {
  console.log(`event type is: ${eventType}`);
  if (filename) {
    console.log(`filename provided: ${filename}`);
  } else {
    console.log('filename not provided');
  }
  const nginx_cfg = spawn('service', ['nginx', 'reload']);
});

for (let j = 0; j < process.argv.length; j++) {
  console.log(j + ' -> ' + (process.argv[j]));
}
// first two are node and script name
const paras = process.argv.slice(2)
if (paras.length == 0) {
  return console.log('please input domain name for fully functional !!!')
}
const domain = paras[0];
const user = paras[1] || 'freego';
const pass = paras[2] || "freego2018";
const key = paras[3] || "freego2018";
const email = paras[4] || `${user}@${domain}`;
if (!fs.existsSync(`/etc/letsencrypt/live/${domain}`)) {
  // letsencrypt certonly --standalone --agree-tos --preferred-challenges http-01 --email $em -d $dn
  // let ret = spawnSync('letsencrypt', ['certonly', '--standalone', '--agree-tos', '--email', email, '-d', domain]);
  (function req_cert(){
    if(nginx_available){
      const ret = spawnSync('/script/reqcert.js', [domain, email]);
      const std_out = ret.stdout.toString();
      const std_err = ret.stderr.toString();
      if (std_out.indexOf('Congratulations!') < 0) {
        console.log('request certificate failed')
        console.log(std_out)
        console.log(std_err)
        return;
      }
      console.log(std_out)
      start_service()
    } else {
      setTimeout(req_cert, 100)
      console.log('wait for nginx ready...')
    }
  })()
} else {
  const ret = spawnSync('letsencrypt', ['renew']);
  console.log(ret.stdout.toString())
  start_service()
}
function start_service() {
  const cert = `/etc/letsencrypt/live/${domain}/fullchain.pem`;
  const privkey = `/etc/letsencrypt/live/${domain}/privkey.pem`;
  let ret = spawnSync('vpnserver', ['start'])  
  console.log('softether vpn started !!!')
  execSync("sleep 1") //wait for 1 second
  ret = spawnSync('vpncmd', ['localhost:992', '/SERVER', '/CMD', 'ServerPasswordSet', 'freego']);
  // ret = spawnSync('vpncmd', ['localhost:992', '/SERVER', '/PASSWORD:freego', '/CMD', 'ListenerDelete', '443']);
  console.log('11111111111111111111111111111111')
  ret = spawnSync('vpncmd', ['localhost:992', '/SERVER', '/PASSWORD:freego', '/adminhub:DEFAULT', '/CMD', 'SecureNatEnable']);
  console.log('22222222222222222222222222222222')
  ret = spawnSync('vpncmd', ['localhost:992', '/SERVER', '/PASSWORD:freego', '/adminhub:DEFAULT',
    '/CMD', 'UserCreate', user, '/GROUP:none', '/REALNAME:none', '/NOTE:none']);
  console.log('33333333333333333333333333333333')  
  ret = spawnSync('vpncmd', ['localhost:992', '/SERVER', '/PASSWORD:freego', '/adminhub:DEFAULT',
    '/CMD', 'UserPasswordSet', user, `/PASSWORD:${pass}`, '/REALNAME:none', '/NOTE:none']);
  console.log('44444444444444444444444444444444')  
  ret = spawnSync('vpncmd', ['localhost:992', '/SERVER', '/PASSWORD:freego', '/adminhub:DEFAULT',
    '/CMD', 'IPsecEnable', '/L2TP:yes', `/L2TPRAW:yes`, '/ETHERIP:yes', `/PSK:${key}`, '/DEFAULTHUB:DEFAULT']);
  console.log('55555555555555555555555555555555')
  ret = spawnSync('vpncmd', ['localhost:992', '/SERVER', '/PASSWORD:freego',
    '/CMD', 'ServerCertSet', `/LOADCERT:${cert}`, `/LOADKEY:${privkey}`]);
  console.log('66666666666666666666666666666666')
  ret = spawnSync('vpncmd', ['localhost:992', '/SERVER', '/PASSWORD:freego', '/CMD', 'SstpEnable', 'yes']);
  console.log('softether vpn cofiguration completed !!!')
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
  spawnSync('supervisorctl', ['start', 'stunnel', 'nghttpx']);
  console.log('--------------- All service started ---------------')
  const span = 30 * 24 * 3600 * 1000; //30 days
  setInterval(()=>{
    const ret = spawnSync('letsencrypt', ['renew']);
    fs.appendFile('renew_cert.log', ret.stdout.toString(), (err)=> {
      // if (err) throw err;
      // console.log('Saved!');
    });
  }, span)
}



