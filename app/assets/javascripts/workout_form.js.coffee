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

  $('#ex-list tbody').on 'click', '.delete-ex', ->
    $(this).closest('tr').remove()
    exs = $('#ex-list tbody tr').length
    if exs == 0
      $('.empty-msg').css 'display', 'block'
      $('#ex-list').css 'display', 'none'

  $('#workout-offering-fields').on 'click', '.delete-offering', ->
    $(this).closest('.offering').remove()

  $('#btn-submit-wo').click ->
    handle_submit()

  $('#workout-offering-fields').on 'change', '.coff-select', ->
    disabled = $(this).val() == ''
    $(this).closest('.offering').find('.add-extension').attr('disabled', disabled)

# Leave scope of document ready -- helper methods below
fix_helper = (e, ui) ->
  ui.children().each ->
    $(this).width($(this).width())
  return ui

init_datepickers = ->
  workout_offerings = $('#workout-offering-fields').find '.offering'
  for offering in workout_offerings
    do (offering) ->
      init_offering_datepickers offering


init_offering_datepickers = (offering) ->
  if !$(offering).data('date-init')
    opening_datepicker = $(offering).find '.opening-datepicker'
    soft_datepicker = $(offering).find '.soft-datepicker'
    hard_datepicker = $(offering).find '.hard-datepicker'

    opening_datepicker.datetimepicker
      useCurrent: false
      minDate: moment()
    soft_datepicker.datetimepicker
      useCurrent: false
    soft_datepicker.data('DateTimePicker').disable()
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

    $(offering).data('date-init', 'true')

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
    ex_points = $(exs[i]).find('.points').val();
    ex_points = '0' if ex_points == ''
    ex_obj = { id: ex_id, points: ex_points };
    key = i + 1
    exercises[key.toString()] = ex_obj
    i++
  return exercises

handle_submit = ->
  if !check_completeness()
    alert 'Please fill in all required fields.'
    return

  name = $('#wo-name').val()
  description = $('#description').val()
  exercises = get_exercises()
  course_offering_id = $('.coff-select').val();
  opening_date = $('.opening-datepicker').data('DateTimePicker').date().toDate().toString()
  soft = $('.soft-datepicker').data('DateTimePicker').date().toDate().toString()
  hard = $('.hard-datepicker').data('DateTimePicker').date().toDate().toString()
  fd = new FormData
  fd.append 'name', name
  fd.append 'description', description
  fd.append 'exercises', JSON.stringify exercises
  fd.append 'course_offering_id', course_offering_id
  fd.append 'opening_date', opening_date
  fd.append 'soft_deadline', soft
  fd.append 'hard_deadline', hard

  $.ajax
    url: '/gym/workouts/create'
    type: 'post'
    data: fd
    processData: false
    contentType: false
    success: (data) ->
      window.location.href = data['url']
