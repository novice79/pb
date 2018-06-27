#!/usr/bin/node
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
// /usr/bin/supervisord --nodaemon