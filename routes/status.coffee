# jobs.coffee
# Talks with redis to get info on a job
# Copyright 2012 Compucius

# Redis connection
redis = require 'redis'
connect = require 'connect'
redis_client = redis.createClient()
RedisStore = require('connect-redis')(connect)
session_store = new RedisStore {client: redis_client}

exports.index = (req, res) ->
  data = {}
  data.job = req.params.job_id
  data.state = 0
  data.progress = (new Date()).getSeconds()
  data.total = 59
  res.send(data)
