var redis  = require('redis');
var logfmt = require('logfmt');

exports.createClient = function createClient(){
  if (process.env.REDIS_PROVIDER) {
    var url    = require("url").parse(process.env[process.env.REDIS_PROVIDER]);
    var client = redis.createClient(url.port, url.hostname);

    client.auth(url.auth.split(":")[1]);
  } else {
     var client = redis.createClient();
  }

  client.on('error', function(e) { logfmt.error(e) });

  return client;
}
