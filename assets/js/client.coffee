# global socket object
socket = null

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
    console.log 'EMITTING MAP ITEM', o
    socket.emit 'map_data_receive', {
      shard_id: o.shard_id,
      key: o.key,
      value: o.value
    }

  done_map: ->
    console.log 'DONE MAPPING PHASE'
    socket.emit 'done_map'

  emit_reduction: (o) ->
    key = o.key
    value = o.value
    console.log 'EMITTING REDUCTION', o

  done_reduce: ->
    console.log 'DONE REDUCING PHASE'

$ ->
  console.log "Hello world"
  socket = io.connect 'http://local.host:8001'
  socket.emit('hi', 'hello world')
  worker = spawn_webworker(worker_handler)
  worker.compuciusSend 'salute'
  socket.on 'start_job', (data) ->
    if data.type == 'map'
      console.log "STARTING JOB", data
      worker.compuciusSend 'start_map', {
        code: data.code
        chunk: data.data
        shard_count: data.num_shuffle_shards
      }



