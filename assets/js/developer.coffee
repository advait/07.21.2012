#= require './util.coffee'

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
  states = {}
  $('.knob').knob()
  $('.job').each (index, item) ->
    item = $(item)
    id = $(item).attr('id')
    knob = $('#'+id+' .knob')
    socket = io.connect getSocketServerURL()
    socket.emit 'watch job', id
    socket.on 'message', (data) ->
      states = JSON.parse data
      # Mapping phase
      if states.state == 2
        item.children('.state').text('mapping')
        knob.val states.chunks_done
        knob.trigger 'configure',
          'max': '4'
          'fgColor': 'purple'
        knob.trigger 'change'
      # Pre shuffle phase
      if states.state == 3
        item.children('.state').text('pre-shuffling')
        knob.val '100'
        knob.trigger 'configure',
          'max': '100'
          'fgColor': 'orange'
        knob.trigger 'change'
      # Reduce phase
      if states.state == 4
        item.children('.state').text('reducing')
        knob.val '10'
        knob.trigger 'configure',
          'max': '10'
          'fgColor': 'blue'
        knob.trigger 'change'
      # Reduce phase
      if states.state == 5
        item.children('.state').text('done')
        knob.val '100'
        knob.trigger 'configure',
          'max': '100'
          'fgColor': 'green'
        knob.trigger 'change'

  #setInterval update, 1000, 222