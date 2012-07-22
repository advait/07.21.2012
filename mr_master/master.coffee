# Copyright 2012 Compucius
# Date: 07/21/2012
# master.coffee - contains the master class

# Module imports
redis = require 'redis'
mongoose = require 'mongoose'
models = require '../models'
Job = models.Job

mongoose.connect('mongodb://localhost/compucius');

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
      console.log data
      console.log "Found job: '#{job_id}'".blue
      Job.findById job_id, (err, doc) =>
        if (err or not doc?)
          console.log err
          return

        console.log "Found this job"
        console.log doc
        @job = doc
        @updateState MRStates.MAP_DATA

        @mapData()

  mapData: () ->
    if (@state != MRStates.MAP_DATA)
      console.log err
      return

    console.log "Job #{@job._id}: @ Map Data".blue
    # Call mapChunk for each chunk
    @num_map_chunks_done = 0
    for i in [0..@job.data.length - 1]
      @mapChunk i

  # Each map chunk function is responsible for making sure that some client
  # finishes mapping the chunk.
  mapChunk: (chunk_id) ->
    console.log "Job #{@job._id}: chunk #{chunk_id} mapping".blue
    # Allocate a client.
    @client_pool.pop (client) =>
      socket = client.socket
      dc_handler = () ->
        console.log "Client DC: restart mapChunk #{@job._id} > {chunk_id}".red

        mapChunk chunk_id

      # Delete all previous chunk/sharding keys.
      for i in [0..@job.data.length - 1]
        @redis_client.del "job:#{@job._id}:chunk:#{chunk_id}:#{i}"

      socket.on 'map_data_receive', (data) =>
        # Get the shard id from data
        tmp_store = "job:#{@job._id}:chunk:#{chunk_id}:#{data.shard_id}"
        @redis_client.rpush tmp_store, "[#{data.key}, #{data.value}]"


      socket.on 'done_map', (data) =>
        # Remove all listeners set, returns the client back into the pool, and
        # tells the mapper this chunk has finished.
        socket.removeListener 'disconnect', dc_handler
        socket.removeAllListeners 'done_map'
        socket.removeAllListeners 'map_data_receive'
        @client_pool.push client
        @mapFinish()

      socket.on 'disconnect', dc_handler

      # Tell the client to start the job.
      socket.emit 'start_job', {
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
      @updateState MRStates.PRE_SHUFFLE_DATA
      @preshuffleData()

  preshuffleData: () ->
    if (@state != MRStates.PRE_SHUFFLE_DATA)
      console.log err
      return



    console.log "PRESHUFFLING DATA!".red
    for x in [0..(@job.shard_count - 1)]
      @redis_client.del "job:#{@job._id}:shard:#{x}"
      all_values_for_shard = []
      for y in [0..@job.data.length - 1]
        func = () =>
          i = x
          j = y
          tmp_store = "job:#{@job._id}:chunk:#{j}:#{i}"
          @redis_client.lrange "job:#{@job._id}:chunk:#{j}:#{i}", 0, -1, (err, reply) =>
            if (err)
              console.log err
              return
            tmp_store = "job:#{@job._id}:shard:#{i}"
            for item in reply
              @redis_client.rpush tmp_store, item, (err, reply) ->
                if err?
                  console.log err
                  return
        func()

    @updateState MRStates.SHUFFLE_REDUCE_DATA

    @num_shards_done = 0
    for i in [0..@job.shard_count - 1]
      @shuffleReduceShard i

  shuffleReduceShard: (shard_id) ->
    @client_pool.pop (client) =>
      socket = client.socket
      dc_handler = () ->
        console.log "Client DC: restart shuffleReduceShard #{@job._id} > {shard_id}".red
        shuffleReduceShard shard_id

      socket.on 'reduce_data_recieve', (data) =>
        tmp_store = "job:#{@job._id}:result"
        @redis_client.hset tmp_store, data.key, data.value

      socket.on 'done_reduce', (data) =>
        @redis_client.del "job:#{@job._id}:shard:#{shard_id}"
        socket.removeListener 'disconnect', dc_handler
        socket.removeAllListeners 'done_reduce'
        socket.removeAllListeners 'reduce_data_recieve'
        @client_pool.push client
        @shuffleReduceFinish()

      socket.on 'disconnect', dc_handler

      tmp_store = "job:#{@job._id}:shard:#{shard_id}"
      @redis_client.lrange tmp_store, 0, -1, (err, shard) =>
        if (err)
          console.log err
          return

        socket.emit 'start_job', {
          type: 'reduce'
          code: @job.code
          data: shard
        }
        
  shuffleReduceFinish: () ->
    @num_shards_done += 1

    console.log "Shards finished: #{@num_shards_done}".red
    if (@num_shards_done == @job.data.length)
      @redis_client.hgetall "job:#{@job._id}:result", (result) =>
        @job.result = result
        @job.save()
        @redis_client.del "job:#{@job._id}:result"
        @updateState MRStates.DONE


  done: () ->

  updateState: (newState) ->
    @state = newState
    r_key = "job:{@job._id}:state"
    @redis_client.set r_key, @state
    console.log "Job #{@job._id} new state: #{@state}".green

