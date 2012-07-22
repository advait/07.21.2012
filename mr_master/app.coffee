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

mt = new master.Master []
mt.startJob()