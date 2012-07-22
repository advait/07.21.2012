# Copyright 2012 Compucius
# Date: 07/21/2012
# master.coffee - contains the master class

# Module imports
redis = require 'redis'

# App imports
models = require '../models'

# Master states
MRStates =
  START: 0
  CHUNK_DATA: 1
  MAP_DATA: 2
  PRE_SHUFFLE_DATA: 3
  SHUFFLE_REDUCE_DATA: 4
  DONE: 5

# Master constants
constants =
  R_JOB_QUEUE = 'job_queue'

# Master class
class exports.Master

  # Args:
  #   clientPool - A pool of clients to use.
  constructor: (clientPool) ->
    @client_pool = clientPool
    @redis_client = redis.createClient()
    @state = MRStates.START

  startJob: () ->
    # Ensure correct state.
    if (@state != MRStates.START)
      console.log "startJob: Can't start while in state #{@state}".red
      return

    # Get the next queued up job.
    console.log 'Looking for next queued job'.blue
    @redis_client.blpop R_JOB_QUEUE, 0, (err, data) =>
      # Make sure there aren't any errors.
      if (err)
        console.log err
        return

      # Print data
      job_id = data[1]
      console.log "Found job: '#{job_id}'".blue
      models.Job.findById job_id, (error, job) ->
        console.log error
        console.log job

  chunkData: () ->
  mapData: () ->
  preshuffleData: () ->
  done: () ->

