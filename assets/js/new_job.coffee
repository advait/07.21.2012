# Adding jobs
$ ->
  $('#new-submit').click (e) ->
    code = $('#code').text()
    console.log code

    # Code doesn't have functions required
    ###
    if code.indexOf('generateChunk(') == -1 or
       code.indexOf('generateMap(') == -1 or
       code.indexOf('generateReduction(') == -1
      $('#invalid').show()
      return
    ###

    # Code passed validation
    $('#invalid').hide()
    new_job =
      name: $('#name').val()
      data_type: $('#data_type').val()
      data: $('#data').val()
      code: $('#code').val()
      shard_count: $('#shard_count').val()
    console.log new_job
    $.post '/jobs/new', new_job, (data) ->
      console.log data

