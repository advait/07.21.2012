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
    cur_state = 0

    socket.on id, (data) ->
      states = JSON.parse data
      window.states = states

      # Change states
      if states.change? || cur_state == 0
        cur_state = states.state
        switch states.state
          # Mapping phase
          when 2
            item.children('.state').text('mapping')
            knob.val 0
            knob.trigger 'configure',
              'max': states.chunk_total
              'fgColor': 'purple'

          # Pre shuffle phase
          when 3
            item.children('.state').text('pre-shuffle')
            knob.val 10
            knob.trigger 'configure',
              'max': 10
              'fgColor': 'orange'

          # Reduce phase
          when 4
            item.children('.state').text('reducing')
            knob.val 0
            knob.trigger 'configure',
              'max': states.shard_total
              'fgColor': 'blue'

          # Done
          when 5
            item.children('.state').text('done')
            knob.trigger 'configure',
              'max': '100'
              'fgColor': 'green'

      # Increment value
      else
        switch states.state
          when 2
            knob.val(states.done).trigger('change')
          when 4
            knob.val(states.done).trigger('change')
          when 5
            knob.val(100).trigger('change')

  $('.job').click (e) ->
    id = $(this).attr('id')
    $.get "/result/#{id}", (data) ->
      $('#results .modal-header h3').text(data.name)
      $('#results .modal-body pre').text(JSON.stringify(data.results, undefined, 2))
    $('#results').modal('show')
