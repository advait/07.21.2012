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
client = require('./client')
master = require './master'
models = require '../models'

# Redis things
redis_client = redis.createClient()
RedisStore = require('connect-redis')(connect)
session_store = new RedisStore {client: redis_client}
client_pool = new client.ClientPool()

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

# Socket settings
# turn off some logs
sio.configure ()->
  sio.set('log level', 0)

sio.sockets.on 'connection', (socket) ->

  hs = socket.handshake
  # Create new Client and add it to the free clients
  newClient = new client.Client socket, hs.session.auth.facebook.user.id
  client_pool.push newClient
  console.log "Socket from #{hs.session.auth.facebook.user.name}".green

  socket.on 'disconnect', ->
    # Remove client from free queue
    client_pool.remove newClient

# Create a master worker
mt = new master.Master client_pool
mt.startJob()
