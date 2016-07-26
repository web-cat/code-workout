$('.workouts-new').ready ->
  sortable = $('#ex-list tbody').sortable
    handle: '.handle'
    helper: fix_helper

  sortable.disableSelection()

  init_datepickers()

  $('.search-results').on 'click', '.add-ex', ->
    $('.empty-msg').css 'display', 'none'
    $('#ex-list').css 'display', 'block'
    ex_name = $(this).data('ex-name')
    ex_id = $(this).data('ex-id')
    exercise_row =
      "<tr data-id='" + ex_id + "'>" +
        "<td><i class='handle fa fa-bars'></i></td>" +
        "<td>" + ex_name + "</td>" +
        "<td><input class='points form-control input-sm' placeholder='e.g 5' type='number' min='0' value='0' /></td>" +
        "<td><i class='delete fa fa-times'></i></td>" +
      "</tr>"
    $('#ex-list tbody').append(exercise_row);

  $('#add-offering').on 'click', ->
    $('#workout-offering-fields').append($('#add-offering-form').html())
    init_datepickers()

  $('#workout-offering-fields').on 'click', '.delete-offering', ->
    $(this).closest('.offering').remove()

  $('#workout-offering-fields').on 'change', '.coff-select', ->
    val = $(this).val()
    if val != ''
      $(this).closest('.offering').attr('id', 'off-' + val)

  $(document).on 'click', '.add-extension', ->
    course_offering_id = $(this).closest('tr').find('.coff-select').val()
    if course_offering_id != ''
      $(this).closest('.offering').find('.extensions').css 'display', 'inline'
      $.ajax
        url: '/course_offerings/' + course_offering_id + '/students'
        type: 'get'
        cache: true
        dataType: 'script'
        success: (data) ->
          init_datepickers()

  $(document).on 'click', '.delete-extension', ->
    $(this).closest('tr').remove()

  $('#ex-list tbody').on 'click', '.delete-ex', ->
    $(this).closest('tr').remove()
    exs = $('#ex-list tbody tr').length
    if exs == 0
      $('.empty-msg').css 'display', 'block'
      $('#ex-list').css 'display', 'none'

  $('#btn-submit-wo').click ->
    handle_submit()

# Leave scope of document ready -- helper methods below

# Helper method for making table sortable.
fix_helper = (e, ui) ->
  ui.children().each ->
    $(this).width($(this).width())
  return ui

init_datepickers = ->
  workout_offerings = $('.offering-fields', '#workout-offering-fields')
  for offering in workout_offerings
    do (offering) ->
      field_rows = $('.fields', $(offering))
      for field_row in field_rows
        do (field_row) ->
          init_offering_datepickers field_row


init_offering_datepickers = (offering) ->
  opening_datepicker = $('input.opening-datepicker', $(offering))
  soft_datepicker = $('input.soft-datepicker', $(offering))
  hard_datepicker = $('input.hard-datepicker', $(offering))

  if opening_datepicker.val() == '' || !opening_datepicker.data('DateTimePicker').date()?
    opening_datepicker.datetimepicker
      useCurrent: false
      minDate: moment()
  if soft_datepicker.val() == '' || !soft_datepicker.data('DateTimePicker').date()?
    soft_datepicker.datetimepicker
      useCurrent: false
    soft_datepicker.data('DateTimePicker').disable()
  if hard_datepicker.val() == '' || !hard_datepicker.data('DateTimePicker').date()?
    hard_datepicker.datetimepicker
      useCurrent: false
    hard_datepicker.data('DateTimePicker').disable()

  # Handle date change events
  opening_datepicker.on 'dp.change', (e) ->
    if e.date?
      soft_datepicker.data('DateTimePicker').enable()
      soft_datepicker.data('DateTimePicker').minDate e.date
      hard_datepicker.data('DateTimePicker').minDate e.date

  soft_datepicker.on 'dp.change', (e) ->
    if e.date?
      hard_datepicker.data('DateTimePicker').enable()
      opening_datepicker.data('DateTimePicker').maxDate e.date
      hard_datepicker.data('DateTimePicker').minDate e.date

  hard_datepicker.on 'dp.change', (e) ->
    if e.date?
      soft_datepicker.data('DateTimePicker').maxDate e.date

check_completeness = ->
  complete = true
  complete = false if $('#wo-name').val() == ''
  complete = false if $('#ex-list tbody tr').length == 0
  complete = false if (!$('.coff-select').val? || $('.coff-select').val() == '')
  complete = false if !$('.opening-datepicker').data('DateTimePicker').date()?
  complete = false if !$('.soft-datepicker').data('DateTimePicker').date()?
  complete = false if !$('.hard-datepicker').data('DateTimePicker').date()?

  return complete

get_exercises = ->
  exs = $('#ex-list tbody tr')
  exercises = {}
  i = 0
  while i < exs.length
    ex_id = $(exs[i]).data('id')
    ex_points = $(exs[i]).find('.points').val()
    ex_points = '0' if ex_points == ''
    ex_obj = { id: ex_id, points: ex_points }
    position = i + 1
    exercises[position.toString()] = ex_obj
    i++
  return exercises

get_offerings = ->
  offerings = {}
  offering_tables = $('table', '#workout-offering-fields') # Each offering is in its own table

  # The first row of each table contains offering fields. Each subsequent row
  # contains fields for student extensions.
  for table in offering_tables
    #  Get input data for each offering.
    do (table) ->
      offering_row = $('tr', $(table)).filter ':eq(1)'  # Get the first row
      offering_fields = $('td', $(offering_row))
      offering_id = $('.coff-select', $(offering_fields[0])).val()
      policy_id = $('.policy-select', $(offering_fields[1])).val()
      time_limit = $('.time-limit', $(offering_fields[2])).val()
      opening_date = $('.opening-datepicker', $(offering_fields[3])).data('DateTimePicker').date().toDate().toString()
      soft_deadline = $('.soft-datepicker', $(offering_fields[4])).data('DateTimePicker').date().toDate().toString()
      hard_deadline = $('.hard-datepicker', $(offering_fields[5])).data('DateTimePicker').date().toDate().toString()
      offering =
        workout_policy_id: policy_id
        time_limit: time_limit
        opening_date: opening_date
        soft_deadline: soft_deadline
        hard_deadline: hard_deadline
      extensions = []
      extension_rows = $('tr', $(table)).filter ':gt(1)'  # Get all rows after the first one
      for row in extension_rows
        # Get input data for each extension within the offering.
        do (row) ->
          extension_fields = $('td', $(row))
          students = $('.student-select', $(extension_fields[0])).val()
          time_limit = $('.time_limit', $(extension_fields[2])).val()
          opening_date = $('.opening-datepicker', $(extension_fields[3])).data('DateTimePicker').date().toDate().toString()
          soft_deadline = $('.soft-datepicker', $(extension_fields[4])).data('DateTimePicker').date().toDate().toString()
          hard_deadline = $('.hard-datepicker', $(extension_fields[5])).data('DateTimePicker').date().toDate().toString()
          extension =
            students: students
            time_limit: time_limit
            opening_date: opening_date
            soft_deadline: soft_deadline
            hard_deadline: hard_deadline
          extensions.push extension
      offering['extensions'] = extensions
      offerings[offering_id.toString()] = offering
  return offerings

handle_submit = ->
  # if !check_completeness()
  #   alert 'Please fill in all required fields.'
  #   return
  #
  name = $('#wo-name').val()
  description = $('#description').val()
  exercises = get_exercises()
  course_offerings = get_offerings()
  fd = new FormData
  fd.append 'name', name
  fd.append 'description', description
  fd.append 'exercises', JSON.stringify exercises
  fd.append 'course_offerings', JSON.stringify course_offerings

  $.ajax
    url: '/gym/workouts'
    type: 'post'
    data: fd
    processData: false
    contentType: false
    success: (data) ->
      window.location.href = data['url']
