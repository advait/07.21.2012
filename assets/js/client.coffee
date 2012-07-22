#= require './util.coffee'

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

console.log = () ->
worker_handler =
  log: (message) ->
    console.log 'WORKER SAYS', message

  emit_map_item: (o) ->
    console.log 'EMITTING MAP ITEM', o
    socket.emit 'map_data_receive', o

  done_map: ->
    console.log 'DONE MAPPING PHASE'
    socket.emit 'done_map'

  emit_reduction: (o) ->
    console.log 'EMITTING REDUCTION', o
    socket.emit 'reduce_data_recieve', o

  done_reduce: ->
    console.log 'DONE REDUCING PHASE'
    socket.emit 'done_reduce'

$ ->
  console.log "Hello world"
  url = getSocketServerURL()
  console.log url
  socket = io.connect "#{url}:8001"
  socket.emit('hi', 'hello world')
  worker = spawn_webworker(worker_handler)
  worker.compuciusSend 'salute'
  socket.on 'start_job', (data) ->
    if data.type == 'map'
      console.log "STARTING MAP JOB", data
      worker.compuciusSend 'start_map', {
        code: data.code
        chunk: data.data
        data_type: data.data_type
        shard_count: data.num_shuffle_shards
      }
    else if data.type == 'reduce'
      console.log "STARTING REDUCE JOB", data
      worker.compuciusSend 'start_reduce', {
        code: data.code
        tuples: data.data
      }



