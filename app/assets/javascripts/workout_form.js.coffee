$('.workouts.new, .workouts.edit').ready ->
  sortable = $('#ex-list').sortable
    handle: '.handle'

  init_datepickers()
  init_exercises()

  $('.search-results').on 'click', '.add-ex', ->
    $('.empty-msg').css 'display', 'none'
    $('#ex-list').css 'display', 'block'
    ex_name = $(this).data('ex-name')
    ex_id = $(this).data('ex-id')
    data =
      name: ex_name
      id: ex_id
      points: 0
    $.get '/assets/exercise.mustache.html', (template, textStatus, jqXHr) ->
      $('#ex-list').append(Mustache.render($(template).filter('#exercise-template').html(), data))

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
    if course_offering_id == ''
      form_alert ['You must select a course offering before adding student extensions to it.']
    else
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

  $('#ex-list').on 'click', '.delete-ex', ->
    ex_row = $(this).closest 'li'
    ex_workout_id = ex_row.data 'exercise-workout-id'
    console.log ex_workout_id
    if ex_workout_id? && ex_workout_id != ''
      ex_list = $('#ex-list')
      removed_exercises = ex_list.data 'removed-exercises'
      removed_exercises.push ex_workout_id
      ex_list.data('removed_exercises', removed_exercises)
    ex_row.remove()
    exs = $('#ex-list li').length
    if exs == 0
      $('.empty-msg').css 'display', 'block'
      $('#ex-list').css 'display', 'none'

  $('#btn-submit-wo').click ->
    handle_submit()

init_exercises = ->
  exercises = $('#ex-list').data 'exercises'
  if exercises
    $.get '/assets/exercise.mustache.html', (template, textStatus, jqXHr) ->
      for exercise in exercises
        do (exercise) ->
          data =
            id: exercise.id
            exercise_workout_id: exercise.exercise_workout_id
            name: exercise.name
            points: exercise.points
          $('#ex-list').append(Mustache.render($(template).filter('#exercise-template').html(), data))
      $('#ex-list').removeData 'exercises'

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

get_exercises = ->
  exs = $('#ex-list li')
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
      if offering_id != ''
        opening_datepicker = $('.opening-datepicker', $(offering_fields[1])).data('DateTimePicker').date()
        soft_datepicker = $('.soft-datepicker', $(offering_fields[2])).data('DateTimePicker').date()
        hard_datepicker = $('.hard-datepicker', $(offering_fields[3])).data('DateTimePicker').date()

        opening_date = if opening_datepicker? then opening_datepicker.toDate().toString() else null
        soft_deadline = if soft_datepicker? then soft_datepicker.toDate().toString() else null
        hard_deadline = if hard_datepicker? then hard_datepicker.toDate().toString() else null

        offering =
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
            opening_datepicker = $('.opening-datepicker', $(extension_fields[3])).data('DateTimePicker').date()
            soft_datepicker = $('.soft-datepicker', $(extension_fields[4])).data('DateTimePicker').date()
            hard_datepicker = $('.hard-datepicker', $(extension_fields[5])).data('DateTimePicker').date()

            opening_date = if opening_datepicker? then opening_datepicker.toDate().toString() else null
            soft_deadline = if soft_datepicker? then soft_datepicker.toDate().toString() else null
            hard_deadline = if hard_datepicker? then hard_datepicker.toDate().toString() else null
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

form_alert = (messages) ->
  reset_alert_area()

  alert_list = $('#alerts').find '.alert ul'
  for message in messages
    do (message) ->
      alert_list.append '<li>' + message + '</li>'

  $('#alerts').css 'display', 'block'

reset_alert_area = ->
  $('#alerts').find('.alert').alert 'close'
  alert_box =
    "<div class='alert alert-danger alert-dismissable' role='alert'>" +
      "<button class='close' data-dismiss='alert' aria-label='Close'><i class='fa fa-times'></i></button>" +
      "<ul></ul>" +
    "</div>";
  $('#alerts').append alert_box

check_completeness = ->
  messages = []
  messages.push 'Workout Name cannot be empty.' if $('#wo-name').val() == ''
  messages.push 'Workout must have at least 1 exercise.' if $('#ex-list li').length == 0

  if $('body').hasClass '.workouts.new'
    course_offering_selects = $('#workout-offering-fields').find '.coff-select'
    coff_errs = 0
    for select in course_offering_selects
      do (select) ->
        coff_errs = coff_errs + 1 if $(select).val() == ''
    messages.push 'You must select a Course Offering for this Workout. (x' + coff_errs + ')' if coff_errs > 0

  return messages

handle_submit = ->
  messages = check_completeness()
  if messages.length != 0
    form_alert messages
    return

  name = $('#wo-name').val()
  description = $('#description').val()
  time_limit = $('#time-limit').val()
  policy_id = $('#policy-select').val()
  removed_exercises = $('#ex-list').data 'removed-exercises'
  exercises = get_exercises()
  course_offerings = get_offerings()
  fd = new FormData
  fd.append 'name', name
  fd.append 'description', description
  fd.append 'time_limit', time_limit
  fd.append 'policy_id', policy_id
  fd.append 'exercises', JSON.stringify exercises
  fd.append 'course_offerings', JSON.stringify course_offerings
  fd.append 'removed_exercises', removed_exercises

  if $('body').is('.workouts.new')
    url = '/gym/workouts'
    type = 'post'
  else if $('body').is('.workouts.edit')
    can_update = $('#workout-offering-fields').data 'can-update'
    url = if can_update == true then '/gym/workouts/' + $('h1').data 'id' else '/gym/workouts'
    type = if can_update == true then 'patch' else 'post'

  $.ajax
    url: url
    type: type
    data: fd
    processData: false
    contentType: false
    success: (data) ->
      window.location.href = data['url']
