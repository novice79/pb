#!/usr/bin/env node
const fs = require('fs');
const { spawn, spawnSync } = require('child_process');
// first two are node and script name
const paras = process.argv.slice(2)
if (paras.length == 0) {
    return console.log('please input domain name for request cert !!!')
}
const conf_path = '/etc/nginx/conf.d/'
const domain = paras[0];
const email = paras[1] || `${require("os").userInfo().username}@${domain}`;
let data = {
    domain
}
const templ = fs.readFileSync('/script/tmpl.conf', "utf8")
let cfg = templ.replace(/\${([^}]*)}/g, (r, k) => {
    // console.log(r, k)
    return data[k] || r;
});

// console.log(cfg)
const cfg_name = `${conf_path}${domain.replace(/\./g, '_')}.conf`;
// console.log(cfg_name)
fs.writeFileSync(cfg_name, cfg)
// console.log(`The ${cfg_name} file has been saved to ${conf_path}!`);
spawnSync('service', ['nginx', 'reload']);

// request cert use nginx here
let ret = spawnSync('letsencrypt', ['certonly', '--webroot', '-w', '/var/www/ssl-proof/', '--agree-tos', '--email', email, '-d', domain]);
const std_out = ret.stdout.toString();
const std_err = ret.stderr.toString();
if (std_out.indexOf('Congratulations!') < 0) {
    console.log('request certificate failed')
    console.log(std_out)
    console.error(std_err)
    return;
}
console.log(std_out)
cfg = cfg.replace(/###/g, '')
fs.writeFileSync(cfg_name, cfg)
console.log(`The ${cfg_name} file has been saved to ${conf_path}!`);
spawnSync('service', ['nginx', 'reload']);

console.log(`request cert of ${domain} success, open https://${domain} to see`)