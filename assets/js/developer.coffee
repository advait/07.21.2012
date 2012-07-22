update = (job_id) ->
  # Make or find the knob
  if $('#knob-' + job_id).length == 0
    $('#knobs').append '<input id="knob-' + job_id + '" type="text" class="knob" data-readOnly="true" data-thickness=".15">'

  knob = $('#knob-' + job_id)
  knob.knob()

  $.getJSON('/status/3241', (data) ->
    knob.val(data.progress)
    knob.trigger 'change'
    knob.trigger 'configure',
      'max': data.total + ''
      'fgColor': '#66CC66'
    console.log data
  )

$ ->
  socket = io.connect 'http://local.host:8000'
  socket.emit 'watch job', 222
  socket.on 'message', (data) ->
    console.log data

  #setInterval update, 1000, 222