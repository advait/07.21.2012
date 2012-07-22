
# Returns the socket.io url
# Args:
#   [port] - Optional Integer. Defaults to current port.
@getSocketServerURL = (port) ->
  port = if port? then ":#{port}" else ""
  "http://#{window.location.hostname}#{port}"
