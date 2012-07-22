spawn_webworker = (handler) ->
  worker = new Worker('/js/webworker.js')
  # Setup send wrapper
  worker.compuciusSend = (command, data) ->
    worker.postMessage {command:command, data:data}
  # Setup message handlers
  worker.onmessage = (event) ->
    handler[event.data.command](event.data.data)
  return worker


worker_handler =
  log: (message) ->
    console.log 'WORKER SAYS', message

  emit_map_item: (o) ->
    shard_id = o.shard_id
    key = o.key
    value = o.value
    console.log 'EMITTING MAP ITEM', o

  done_map: ->
    console.log 'DONE MAPPING PHASE'

  emit_reduction: (o) ->
    key = o.key
    value = o.value
    console.log 'EMITTING REDUCTION', o

  done_reduce: ->
    console.log 'DONE REDUCING PHASE'

socket_handler =
  v: null

$ ->
  console.log "Hello world"
  socket = io.connect 'http://local.host:8001'
  socket.emit('hi', 'hello world')
  worker = spawn_webworker(worker_handler)
  worker.compuciusSend 'salute'
