#index.coffee
# Copyright 2012 Compucius

access_token = '2334787993255525024264726173982699884554'

models = require '../models'
redis = require 'redis'
connect = require 'connect'

# Redis things
redis_client = redis.createClient()
RedisStore = require('connect-redis')(connect)
session_store = new RedisStore {client: redis_client}

exports.index = (req, res) ->
  console.log 'REQUEST'.red, req.user
  sayings = [
    'A friend asks only for your time, not your money.'
    'A friend asks only for your time, not your money.'
    'Your infinite capacity for patience will be rewarded sooner or later.'
    'Fortune Not Found: Abort, Retry, Ignore?'
    'Time is precious, but truth is more precious than time.'
    'There is no wisdom greater than kindness.'
    'The sure way to predict the future is to invent it.'
  ]
  saying = sayings[Math.floor(Math.random()*sayings.length)]
  res.render "index",
    title: 'Home'
    saying: saying

exports.jobs = (req, res) ->
  if !req.user?
    res.send('must be logged in')
  models.Job.find {}, (err, jobs) ->
    if jobs.length == 0
      console.log 'couldnt find'.red
    res.render 'jobs',
      title: 'Jobs'
      jobs: jobs

exports.client = (req, res) ->
  res.render 'client',
    title: 'Client'

exports.result = (req, res) ->
  models.Job.findById req.params.id, (err, doc) ->
    console.log doc
    res.send {
      name: doc.name
      results: doc.results
    }

exports.jobs_new = (req, res) ->
  default_code = """
generateChunk(key) {
  return [{key: value}];
}

generateMap(key, value) {
  return [{key: value}];
}

generateReduction(key, value) {
  return [{key: value}];
}
  """
  res.render 'new_job',
    title: 'New Job'
    default_code: default_code
    
exports.jobs_new_process = (req, res) ->
  # Chunk the data
  if (req.body.data_type == 'text')
    if req.body.num_chunks? then num_chunks = req.body.num_chunks else num_chunks = 10
    data_chunks = []
    local_chunk = []
    lines = req.body.data.split '\n'
    chunk_size = lines.length / num_chunks
    for line in lines
      local_chunk.push line
      if local_chunk.length >= chunk_size
        data_chunks.push local_chunk.join '\n'
        local_chunk = []
    data_chunks.push local_chunk.join '\n'

  devid = if req.user? then req.user._id else if req.body.uid then req.body.uid
  models.User.findById devid, (err, usr)->
    if (err)
      consol.log err
      return
    if (!usr?)
      res.send 'failure', 400
      return

    new_job = new models.Job(
      name: req.body.name
      data_type: req.body.data_type
      data: data_chunks
      code: req.body.code
      shard_count: Number(req.body.shard_count)
      dev_id: devid
    )

    new_job.save (err) ->
      if !err
        # success
        res.send 'success', 200
        redis_client.rpush 'job_queue', String(new_job._id)
      else
        res.send 'failure', 400
        console.log err
