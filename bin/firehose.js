#! /usr/bin/env node

var WebSocket = require('ws');
var logfmt = require('logfmt');
var redis = require('../redis');

var ws = new WebSocket(process.env.FIREHOSE_URL);

var client = redis.createClient();

ws.on('open', function() {
  console.log('opened websocket connection');
});

ws.on('message', function(_data, flags) {
  var data = JSON.parse(_data);

  if(data.action === 'deploy-app'){
    var appName = data.target;
    var timer = logfmt.time();
    client.rpush('deploys', appName, function(){
      timer.log({deploy: appName})
    });
  }
});
