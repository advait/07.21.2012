#= require './util.coffee'

$ ->
  states = {}
  $('.knob').knob()
  $('.job').each (index, item) ->
    item = $(item)
    id = $(item).attr('id')
    knob = $('#'+id+' .knob')
    socket = io.connect getSocketServerURL()
    socket.emit 'watch job', id
    socket.on id, (data) ->
      states = JSON.parse data
      console.log states.state
      # Mapping phase
      if states.state == 2
        item.children('.state').text('mapping')
        if states.chunks_done?
          knob.val states.chunks_done
        knob.trigger 'change'
        knob.trigger 'configure',
          'max': '10'
          'fgColor': 'purple'
        knob.trigger 'change'
      # Pre shuffle phase
      if states.state == 3
        item.children('.state').text('pre-shuffling')
        knob.val '100'
        knob.trigger 'change'
        knob.trigger 'configure',
          'max': 100
          'fgColor': 'orange'
        knob.trigger 'change'
      # Reduce phase
      if states.state == 4
        item.children('.state').text('reducing')
        if states.shads_done?
          knob.val states.shards_done
        knob.trigger 'change'
        knob.trigger 'configure',
          'max': 5
          'fgColor': 'blue'
        knob.trigger 'change'
      # Reduce phase
      if states.state == 5
        item.children('.state').text('done')
        knob.val 5
        knob.attr('value', 100)
        knob.trigger 'change'
        knob.trigger 'configure',
          'max': '5'
          'fgColor': 'green'
        knob.trigger 'change'
      knob.trigger 'change'
      console.log knob.val()

  $('.job').click (e) ->
    id = $(this).attr('id')
    $.get "/result/#{id}", (data) ->
      $('#results .modal-header h3').text(data.name)
      $('#results .modal-body pre').text(JSON.stringify(data.results, undefined, 2))
    $('#results').modal('show')
