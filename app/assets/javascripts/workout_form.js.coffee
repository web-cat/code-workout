$('#main').ready ->
  $('.ex-area').append("<button id='temp_button'>Mock Submit</button>")
  $('.search-results').on 'click', '.add-ex', ->
    ex_name = $(this).data('ex-name')
    ex_id = $(this).data('ex-id')
    $('#ex-list').append("<li class='list-group-item' data-id='" + ex_id + "'><i class='handle fa fa-bars'></i>" + ex_name + "</li>");
  $('#ex-list').sortable
    handle: '.handle'

  $('#temp_button').click ->
    exs = $('#ex-list li')
    exercises = {}
    i = 0
    while i < exs.length
      da_id = $(exs[i]).data('id')
      key = i + 1
      exercises[key.toString()] = da_id
      i++

    console.log exercises
