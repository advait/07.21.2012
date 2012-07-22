$ ->
  console.log "Hello world"
  socket = io.connect 'http://local.host:8001'
  socket.emit('hi', 'hello world')