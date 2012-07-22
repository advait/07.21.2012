# Copyright 2012 Compucius
# Date: 07/21/2012
# client.coffee - contains the client class

ClientStates =
  BUSY: 0
  FREE: 1

class exports.Client

  # Args:
  
  constructor: (socket, userId) ->
    @socket = socket
    @user_id = userId
    @status = ClientStates.FREE


# The Client pool will wrap around an array
class exports.ClientPool

  constructor: () ->
    @clients = []
    @clients.remove = (e) -> @[t..t] = [] if (t = @indexOf(e)) > -1
    @waiting_masters_funcs = []

  # Push the client onto the client pool if there aren't any waiting workers.
  # If there are waiting workers, then use the function queue to call the 
  # callback.
  push: (client) ->
    if (@waiting_masters_funcs.length == 0)
      @clients.push client
    else
      func = @waiting_masters_funcs.shift()
      func client

  # Call the callback with the the next client in the pool. If there isn't one,
  # then register the callback for when we do have one.
  pop: (callback) ->
    if (@clients.length == 0)
      @waiting_masters_funcs.push callback
    else
      client = @clients.shift()
      callback client

  remove: (e) ->
    @clients.remove e

