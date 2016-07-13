$('#main').ready ->
  $('.search-results').on 'click', '.add-ex', ->
    $('.empty-msg').css 'display', 'none'
    $('#ex-list').css 'display', 'block'
    ex_name = $(this).data('ex-name')
    ex_id = $(this).data('ex-id')
    exercise_row =
                "<li class='list-group-item' data-id='" + ex_id + "'>" +
                  "<div class='row'>" +
                    "<div class='col-sm-1'>" +
                      "<i class='handle fa fa-bars'></i>" +
                    "</div>" +
                    "<div class='col-sm-3'>" +
                      ex_name +
                    "</div>" +
                    "<div class='col-sm-2 col-sm-offset-2'>" +
                      "Points" +
                    "</div>" +
                    "<div class='col-sm-2'>" +
                      "<input class='points form-control input-sm' placeholder='e.g 5' type='number' min='0' value='0' />" +
                    "</div>" +
                    "<div class='col-sm-1 col-sm-offset-1'>" +
                      "<i class='delete fa fa-times'></i>" +
                    "</div>" +
                  "</div>" +
                "</li>";
    $('#ex-list').append(exercise_row);

  $('#ex-list').sortable
    handle: '.handle'

  $('#ex-list').on 'click', '.delete', ->
    $(this).closest('li').remove()
    exs = $('#ex-list li').length
    if exs == 0
      $('.empty-msg').css 'display', 'block'
      $('#ex-list').css 'display', 'none'


  $('#opening-datepicker').datetimepicker();
  $('#soft-datepicker').datetimepicker useCurrent: false
  $('#hard-datepicker').datetimepicker useCurrent: false

  $('#opening-datepicker').on 'dp.change', (e) ->
    $('#soft-datepicker').data('DateTimePicker').minDate e.date
    $('#hard-datepicker').data('DateTimePicker').minDate e.date

  $('#soft-datepicker').on 'dp.change', (e) ->
    $('#opening-datepicker').data('DateTimePicker').maxDate e.date
    $('#hard-datepicker').data('DateTimePicker').minDate e.date

  $('#hard-datepicker').on 'dp.change', (e) ->
    $('#soft-datepicker').data('DateTimePicker').maxDate e.date

  $('#btn-submit-wo').click ->
    if !check_completeness()
      alert 'Please fill in all required fields.'
      return

    name = $('#wo-name').val()
    description = $('#description').val()
    exercises = get_exercises()
    course_offering_id = $('#coff-select').val();
    opening_date = $('#opening-datepicker').data('DateTimePicker').date().toDate().toString()
    soft = $('#soft-datepicker').data('DateTimePicker').date().toDate().toString()
    hard = $('#hard-datepicker').data('DateTimePicker').date().toDate().toString()
    fd = new FormData
    fd.append 'name', name
    fd.append 'description', description
    fd.append 'exercises', JSON.stringify exercises
    fd.append 'course_offering_id', course_offering_id
    fd.append 'opening_date', opening_date
    fd.append 'soft_deadline', soft
    fd.append 'hard_deadline', hard

    $.ajax
      url: '/gym/workouts/new_create'
      type: 'post'
      data: fd
      processData: false
      contentType: false
      success: (data) ->
        console.log data

  check_completeness = ->
    complete = true
    complete = false if $('#wo-name').val() == ''
    complete = false if $('#ex-list li').length == 0
    complete = false if (!$('#coff-select').val? || $('#coff-select').val() == '')
    complete = false if !$('#opening-datepicker').data('DateTimePicker').date()?
    complete = false if !$('#soft-datepicker').data('DateTimePicker').date()?
    complete = false if !$('#hard-datepicker').data('DateTimePicker').date()?

    return complete

  get_exercises = ->
    exs = $('#ex-list li')
    exercises = {}
    i = 0
    while i < exs.length
      ex_id = $(exs[i]).data('id')
      ex_points = $(exs[i]).find('.points').val();
      ex_points = '0' if ex_points == ''
      ex_obj = { id: ex_id, points: ex_points };
      key = i + 1
      exercises[key.toString()] = ex_obj
      i++
    return exercises
