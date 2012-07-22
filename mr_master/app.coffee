# Copyright 2012 Compucius
# Date: 07/21/2012
# app.coffee - main file for the mr_master

# Module imports.
colors = require 'colors'
connect = require 'connect'
cookie = require 'cookie'
io = require 'socket.io'
redis = require 'redis'

# App imports.
master = require './master'
models = require '../models'

# Redis things
redis_client = redis.createClient()
RedisStore = require('connect-redis')(connect)
session_store = new RedisStore {client: redis_client}

# Create socket for all clients to connect to.
sio = io.listen 8001
sio.set 'authorization', (data, accept) ->
  # Only accept incoming sockets if we have a cookie
  if not data.headers.cookie?
    accept 'No cookies transmitted.', false  # Reject socket
  else
    data.cookie = cookie.parse data.headers.cookie
    data.sid = data.cookie['connect.sid']
    data.session_store = session_store
    session_store.get data.sid, (err, session) ->
      if err or not session? or not session.auth?
        console.log 'REJECTING'
        accept err, false  # Reject socket
      else
        data.session = new connect.middleware.session.Session data, session
        accept null, true  # Accept socket

sio.sockets.on 'connection', (socket) ->
  hs = socket.handshake
  console.log "Socket from #{hs.session.auth.facebook.user.name}".green

# Create a master worker
mt = new master.Master []
mt.startJob()

# Create new job
models.Job.findById '500b859225fc5b6b55000001', (err, doc) ->
  console.log doc
  doc.state = 'queued'
  doc.save()
###
job = new models.Job()
job.state = 'queued'
job.devId = 1054530821
job.code = '
map = function(chunkId, chunk) {
  for (var i = 0; i < chunk.length; i++) {
    emitMapItem(chunk[i], 1);
  }
};

reduce = function(key, values) {
  s = 0;
  for (var i = 0; i < values.length; i++) {
    s += values[i];
  }
  emitReduction(key, s);
};
'
job.data.push '
hello world, i am a string that is really cool
i hope that you have a GREAT day. MY knee hurts'
job.data.push '
whats wrong with the world mama am i really
going to code this much? i think so, woo! ya'
job.shard_count = 2;
console.log 'trying to save'
job.save (err, some) ->
  console.log err
  console.log some###

mt = new master.Master []
mt.startJob()
