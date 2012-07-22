# Copyright 2012 Compucius
# Date: 07/21/2012
# master.coffee - contains the master class

# Module imports
redis = require 'redis'
mongoose = require 'mongoose'
models = require '../models'
Job = models.Job

mongoose.connect('mongodb://compucius:bruin@local.host/compucius');

# App imports
models = require '../models'

# Master states
MRStates =
  START: 0
  MAP_DATA: 2
  PRE_SHUFFLE_DATA: 3
  SHUFFLE_REDUCE_DATA: 4
  DONE: 5

# Master constants
constants =
  R_JOB_QUEUE: 'job_queue'
  R_PRESHUFFLE_CHUNK: 'preshuffle_chunk'
  R_JOB_STATE: 'job_state'


# Master class
class exports.Master

  # Args:
  #   clientPool - A pool of clients to use.
  constructor: (clientPool) ->
    @client_pool = clientPool
    @redis_client = redis.createClient()
    @state = MRStates.START
    @job = null
    @num_map_chunks_done = 0

  startJob: () ->
    # Ensure correct state.
    if (@state != MRStates.START)
      console.log "startJob: Can't start while in state #{@state}".red
      return

    # Get the next queued up job.
    console.log 'Looking for next queued job'.blue
    @redis_client.blpop constants.R_JOB_QUEUE, 0, (err, data) =>
      # Make sure there aren't any errors.
      if (err)
        console.log err
        return

      # Print data
      job_id = data[1]
      console.log "Found job: '#{job_id}'".blue
      Job.findById jobId, (err, doc) =>
        if (err)
          console.log err
          return
        @job = doc
        @updateState MRStates.MAP_DATA

        @mapData()

  mapData: () ->
    if (@state != MRStates.MAP_DATA)
      console.log err
      return

    # Call mapChunk for each chunk
    @num_map_chunks_done = 0
    for i in @job.data.length
      mapChunk i

  # Each map chunk function is responsible for making sure that some client
  # finishes mapping the chunk.
  mapChunk: (chunk_id) ->
    # Allocate a client.
    @client_pool.pop (client) =>
      dc_handler = () ->
        console.log "Client DC: restart mapChunk #{@job._id} > {chunk_id}".red
        mapChunk chunk_id

      client.on 'map_data_receive', (data) ->
        # something

      client.on 'done', (data) ->
        # Remove all listeners set, returns the client back into the pool, and
        # tells the mapper this chunk has finished.
        @client.removeListener 'disconnect', dc_handler
        @client.removeAllListeners 'done'
        @client.removeAllListeners 'map_data_receive'
        @client_pool.push client
        @mapFinish()

      client.on 'disconnect', dc_handler

      # Tell the client to start the job
      client.emit 'start_job', {
        type: 'map'
        code: @job.code
        num_shuffle_shards: @job.shard_count
        data_type: @job.data_type
        data: @job.data[chunk_id]
      }


  mapFinish: () ->
    @num_map_chunks_done += 1

    console.log "Mappers finished: #{@num_map_chunks_done}".red
    if (@num_map_chunks_done == @job.data.length)
      @updateState PRE_SHUFFLE_DATA
      @preshuffleData()

  preshuffleData: () ->

  processPreshuffleShard: (shardId) ->
    @redis_client.get "shardId", (err, reply) ->
      if (err)
        console.log err
        return
      client = client_pool.pop @processPreshuffleShard shardId
      client.on 'done', ->
        client_pool.push client
        if (false)# all shards complete
          @updateState MRStates.DONE
          @job.state = "done"
          @job.save()

        #client.emit
        #client.disconnect

  done: () ->

  updateState: (newState) ->
    @state = newState
    r_key = "#{constants.R_JOB_STATE}:{@job._id}:state"
    @redis_client.set r_key, @state
    console.log "Job #{@job._id} new state: #{@state}".green

