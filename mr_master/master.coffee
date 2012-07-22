# Copyright 2012 Compucius
# Date: 07/21/2012
# master.coffee - contains the master class

# Imports
redis = require 'redis'

# Master states
MRStates =
  START: 0
  CHUNK_DATA: 1
  MAP_DATA: 2
  PRE_SHUFFLE_DATA: 3
  SHUFFLE_REDUCE_DATA: 4
  DONE: 5

# Master class
class exports.Master

  # Args:
  #   clientPool - A pool of clients to use.
  constructor: (clientPool) ->
    @client_pool = clientPool
    @redis_client = redis.createClient()