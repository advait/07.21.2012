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
Client = require('./client').Client
free_clients = []

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

  socket.on 'disconnect', ->
    # Remove client from free queue
    Array::remove = (e) -> @[t..t] = [] if (t = @indexOf(e)) > -1
    free_clients.remove client for client in free_clients when client.socket is socket

    # Remove reassign the client's assigned chunk/shard
    
  hs = socket.handshake

  # Create new Client and add it to the free clients
  newClient = new Client socket, hs.session.auth.facebook.user.id
  free_clients.push newClient
  console.log "Socket from #{hs.session.auth.facebook.user.name}".green

# Create new job
###
job = new models.Job()
job.state = 'queued'
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

console.log 'trying to save'
job.save (err, some) ->
  console.log err
  console.log some###

mt = new master.Master []
mt.startJob()
