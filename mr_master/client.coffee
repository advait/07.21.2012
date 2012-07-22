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


