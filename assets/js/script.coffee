$ ->
  $('.play-button').click (event) ->
    window.open '/client', '_blank', 'width=200, height=200'
    return false