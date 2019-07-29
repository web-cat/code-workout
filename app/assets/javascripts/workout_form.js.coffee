default_point_value = 1
searchable = null

$('.workouts.new, .workouts.edit, .workouts.clone').ready ->
  window.codeworkout ?= {}
  window.codeworkout.removed_exercises = []
  window.codeworkout.removed_offerings = []
  window.codeworkout.removed_extensions = []

  init()
  
  # To allow reordering of exercises
  sortable = $('#ex-list').sortable
    handle: '.handle'
  
  # Add an exercise from search results to the workout
  $('.search-results').on 'click', '.add-ex', ->
    ex_id = $(this).data('ex-id')
    ex_name = $(this).data('ex-name')
    name = "X#{ex_id}"
    can_add = !exercise_is_in_workout(ex_id)
    if can_add
      $('.empty-msg').css 'display', 'none'
      $('#ex-list').css 'display', 'block'
      if ex_name
        name = name + ": #{ex_name}"
      data =
        name: name
        id: ex_id
        points: default_point_value
      template = Mustache.render(
        $(window.codeworkout.exercise_template)
          .filter('#exercise-template').html(),
        data)
      $('#ex-list').append(template)
      close_slider()
    else
      form_alert(["Exercise #{name} has already been added to this workout."])
      exercise = $('#ex-list').find("[data-id=#{ex_id}]")
      exercise.addClass 'shake'
      setTimeout ->
        exercise.removeClass 'shake'
      , 1000
  
  # If we change the point value on an exercise, set the new default
  # to that value, so the user doesn't need to change it each time
  $('#ex-list').on 'change', '.points', ->
    default_point_value = $(this).val()
  
  # From the modal showing available course offerings, add the
  # selected one to this workout
  $('#course-offerings').on 'click', 'a', ->
    course_offering_id = $(this).data 'course-offering-id'
    course_offering_display = $(this).text().trim()
    row = $($('#add-offering-form tbody').html())
    row_fields = row.find('td')
    $(row_fields[0]).data 'course-offering-id', course_offering_id
    $(row_fields[0]).find('.display').html course_offering_display
    init_row_datepickers row
    $(this).remove()
    $('#offerings-modal').modal 'hide'
    $('#workout-offering-fields tbody').append row
  
  # Remove the course offering from this workout
  # If removable, it will again show up as 'available'
  $('#workout-offering-fields').on 'click', '.delete-offering', ->
    row = $(this).closest 'tr'
    workout_offering_id = row.data 'id'
    course_offering_id = row.find('.course-offering').data 'course-offering-id'
    course_offering_display = row.find('.course-offering .display').text()
    removable = $(this).data 'removable'
    if removable
      delete_confirmed = false
      if course_offering_id != ''
        course_offering_id = parseInt(course_offering_id)
        delete_confirmed = remove_extensions_if_any course_offering_id

      if delete_confirmed
        if workout_offering_id? && workout_offering_id != ''
          window.codeworkout.removed_offerings.push workout_offering_id
        row.remove()
        $('#offerings-modal .msg').empty()
        unused_row =
          "<a class='list-group-item action' data-course-offering-id='" +
            course_offering_id + "'>" +
            course_offering_display +
          "</a>"
        $('#offerings-modal #course-offerings').append unused_row
    else
      alert 'Cannot delete this workout. Some students have already attempted it.'

  # Show the StudentSearch modal
  $('#workout-offering-fields').on 'click', '.add-extension', ->
    course_offering = $(this).closest('tr').find('.course-offering')
    course_offering_display = $(course_offering).text()
    course_offering_id = $(course_offering).data 'course-offering-id'
    $('#student-search-modal').modal('show')
    searchable = $('.searchable').StudentSearch
      course_offering_display: course_offering_display
      course_offering_id: course_offering_id
  
  # When a student is selected, use the mustache template to add an extension
  # for that student
  $('.searchable').on 'studentSelect', (e) ->
    if (searchable)
      $('#student-search-modal').modal('hide')
      name = if e.student_name.length > 1 then e.student_name else e.student_display
      data =
        course_offering_id: searchable.course_offering.id
        course_offering_display: searchable.course_offering.display
        student_display: e.student_display
        student_id: e.student_id

      template = $(Mustache.render(
        $(window.codeworkout.student_extension_template)
          .filter('#extension-template').html(),
        data))
      $('#student-extension-fields tbody').append(template)
      $('#student-search-modal').modal('hide')
      $('#extensions').css 'display', 'block'
      init_row_datepickers template
 
  # Remove student extension
  $(document).on 'click', '.delete-extension', ->
    row = $(this).closest('tr')
    extension_id = row.data 'id'
    if extension_id? && extension_id != ''
      window.codeworkout.removed_extensions.push extension_id

    row.remove()
    extensions = $('#student-extension-fields tbody').find 'tr'
    if extensions.length == 0
      $('#extensions').css 'display', 'none'

  # Remove exercise from list
  $('#ex-list').on 'click', '.delete-ex', ->
    ex_row = $(this).closest 'li'
    ex_workout_id = ex_row.data 'exercise-workout-id'
    if ex_workout_id? && ex_workout_id != ''
      window.codeworkout.removed_exercises.push ex_workout_id
    ex_row.remove()
    exs = $('#ex-list li').length
    if exs == 0
      $('.empty-msg').css 'display', 'block'
      $('#ex-list').css 'display', 'none'

  $('#btn-submit-wo').click ->
    handle_submit()

  $('#student-search-modal').on 'shown.bs.modal', ->
    $('#terms').focus()

############################################
# End event handlers, begin helper methods #
############################################

# Initialises the form, including mustache templates and datepickers
init = ->
  description = $('textarea#description').data 'value'
  $('textarea#description').val description
  init_templates()
  course = window.codeworkout.course_id
  if course
    init_datepickers()

# Removes all extensions associated with a workout offering in the form.
# Used when the workout offering itself is being deleted.
# Keeps track of which extensions were removed, so we can tell the backend.
# Asks to confirm first. Returns true if extensions were removed, false 
# otherwise.
remove_extensions_if_any = (course_offering_id) ->
  extensions = $('#student-extension-fields tbody').find 'tr'
  to_remove = []
  for extension in extensions
    do (extension) ->
      offering = $(extension).data 'course-offering-id'
      if offering == course_offering_id
        to_remove.push $(extension).index()

  if to_remove.length > 0
    confirmation = confirm 'Removing this workout offering will also remove ' +
      to_remove.length + ' student extension(s).'
    if confirmation
      for index in to_remove
        do (index) ->
          id = $($(extensions)[index]).data 'id'
          if id? && id != ''
            window.codeworkout.removed_extensions.push id
          $(extensions)[index].remove()

      if extensions.length == 0
        $('#extensions').css 'display', 'none'
      return true
    else
      return false
  else
    return true

# Initialise mustache templates for student extensions and exercises.
init_templates = ->
  $.get window.codeworkout.exercise_template_path, (template, textStatus, jqXHr) ->
    window.codeworkout.exercise_template = template
    if $('body').is('.workouts.edit') || $('body').is('.workouts.clone')
      init_exercises()
  course = window.codeworkout.course_id
  if course
    $.get window.codeworkout.extension_template_path, (template, textStatus, jqXHr) ->
      window.codeworkout.student_extension_template = template
      if $('body').is '.workouts.edit'
        init_student_extensions()

# Display any existing student extensions belonging to workout offerings
# of this workout.
init_student_extensions = ->
  student_extensions = $('#extensions').data 'student-extensions'
  if student_extensions
    $('#extensions').css 'display', 'block' if student_extensions.length > 0
    for extension in student_extensions
      do (extension) ->
        data =
          id: extension.id
          course_offering_id: extension.course_offering_id
          course_offering_display: extension.course_offering_display
          student_id: extension.student_id
          student_display: extension.student_display
          time_limit: extension.time_limit
          opening_date: extension.opening_date * 1000
          soft_deadline: extension.soft_deadline * 1000
          hard_deadline: extension.hard_deadline * 1000
        template =
            $(Mustache.render(
              $(window.codeworkout.student_extension_template)
                .filter('#extension-template').html(),
              data))
        $('#student-extension-fields tbody').append template
        init_row_datepickers template

# Display any existing exercises in this workout.
init_exercises = ->
  exercises = $('#ex-list').data 'exercises'
  if exercises
    for exercise in exercises
      do (exercise) ->
        name = "X#{exercise.id}"
        if exercise.name
          name = name + ": #{exercise.name}"

        # Only keep track of the exercise_workout_id if we're editing a workout
        # If we're creating or cloning a workout, this information is not 
        # required.
        if $('body').is('.workouts.edit')
          exercise_workout_id = exercise.exercise_workout_id
        else
          exercise_workout_id = ''
        data =
          id: exercise.id
          exercise_workout_id: exercise_workout_id
          name: name
          points: exercise.points
        $('#ex-list').append(Mustache.render(
          $(window.codeworkout.exercise_template)
            .filter('#exercise-template').html(),
          data))
    $('#ex-list').removeData 'exercises'

# Initialise the datepickers for each existing workout offering and 
# student extension
init_datepickers = ->
  offerings = $('tr', '#workout-offering-fields tbody')
  for offering in offerings
    do (offering) ->
      init_row_datepickers offering

  extensions = $('tr', '#student-extension-fields tbody')
  for extension in extensions
    do (extension) ->
      init_row_datepickers extension

# Initialise datepickers for a single workout offering or student extension
init_row_datepickers = (row) ->
  opening_input = $('.opening-datepicker', $(row))
  soft_input = $('.soft-datepicker', $(row))
  hard_input = $('.hard-datepicker', $(row))

  opening_datepicker = null
  soft_datepicker = null
  hard_datepicker = null
  alt_format = 'M j, h:i K'
  if opening_input.val() == ''
    opening_datepicker = opening_input.flatpickr
      enableTime: true
      altInput: true
      altFormat: alt_format
      minuteIncrement: 1
      onChange: (selectedDates, dateStr, instance) ->
        if selectedDates.length
          date = selectedDates[0].getTime()
          opening_input.data 'date', date
  if soft_input.val() == ''
    soft_datepicker = soft_input.flatpickr
      enableTime: true
      altInput: true
      altFormat: alt_format
      minuteIncrement: 1
      onChange: (selectedDates, dateStr, instance) ->
        if selectedDates.length
          date = selectedDates[0].getTime()
          soft_input.data 'date', date
  if hard_input.val() == ''
    hard_datepicker = hard_input.flatpickr
      enableTime: true
      altInput: true
      altFormat: alt_format
      minuteIncrement: 1
      onChange: (selectedDates, dateStr, instance) ->
        if selectedDates.length
          date = selectedDates[0].getTime()
          hard_input.data 'date', date

  # Set existing values, if applicable
  if $('body').is '.workouts.edit'
    if opening_input.data('date')? && opening_input.data('date') != ''
      date = parseInt(opening_input.data('date'))
      opening_datepicker.setDate(date, false)

    if soft_input.data('date')? && soft_input.data('date') != ''
      date = parseInt(soft_input.data('date'))
      soft_datepicker.setDate(date, false)

    if hard_input.data('date')? && hard_input.data('date') != ''
      date = parseInt(hard_input.data('date'))
      hard_datepicker.setDate(date, false)

# Close the sidebar housing the exercise search bar. Appears on smaller
# desktop screens.
close_slider = ->
  if $('.sidebar').hasClass('slider') && $('.toggle-slider').attr('data-is-open')
    $('.toggle-slider').click()
    $('#search-terms').val('')
    $('.search-results').empty()

#############################################################
# Collect information from all over the form for submission #
#############################################################

# Get an object array containing all selected exercises.
get_exercises = ->
  exs = $('#ex-list li')
  exercises = []
  i = 0
  while i < exs.length
    ex_id = $(exs[i]).data('id')
    ex_points = $(exs[i]).find('.points').val()
    ex_points = '0' if ex_points == ''
    ex_obj = { id: ex_id, points: ex_points }
    position = i + 1
    exercises.push(ex_obj)
    i++
  return exercises

# Checks if an exercise with the specified ID
# has already been added to the workout.
#
# ex_id -- An integer
exercise_is_in_workout = (ex_id) ->
  for exercise in get_exercises() when exercise['id'] is ex_id
    return true

  return false

# Get an object array of offerings of this workout 
get_offerings = ->
  offerings = {}
  offering_rows = $('tr', '#workout-offering-fields tbody')
  for offering_row in offering_rows
    do (offering_row) ->
      offering_fields = $('td', $(offering_row))
      offering_id = $(offering_fields[0]).data 'course-offering-id'
      lms_assignment_url = $('input', offering_fields[1])[0].value
      if offering_id != ''
        opening_date = $('.opening-datepicker', $(offering_fields[2])).data('date')
        soft_deadline = $('.soft-datepicker', $(offering_fields[3])).data('date')
        hard_deadline = $('.hard-datepicker', $(offering_fields[4])).data('date')

        offering =
          lms_assignment_url: lms_assignment_url
          opening_date: opening_date
          soft_deadline: soft_deadline
          hard_deadline: hard_deadline
          published: published
          extensions: []

        offerings[offering_id.toString()] = offering
  return offerings

# Get all configured workout_offerings along with their student extensions 
get_offerings_with_extensions = ->
  offerings = get_offerings()
  extension_rows = $('tr', '#student-extension-fields tbody')
  for extension_row in extension_rows
    do (extension_row) ->
      extension_fields = $('td', $(extension_row))
      student_id = $(extension_row).data 'student-id'
      course_offering_id = $(extension_row).data 'course-offering-id'
      time_limit = $('.time-limit', $(extension_fields[5])).val()
      opening_date = $('.opening-datepicker', $(extension_fields[2])).data('date')
      soft_deadline = $('.soft-datepicker', $(extension_fields[3])).data('date')
      hard_deadline = $('.hard-datepicker', $(extension_fields[4])).data('date')
      extension =
        student_id: student_id
        time_limit: time_limit
        opening_date: opening_date
        soft_deadline: soft_deadline
        hard_deadline: hard_deadline

      offerings[course_offering_id.toString()]['extensions'].push extension

  return offerings

# Helper method to alert the user of form errors
form_alert = (messages) ->
  reset_alert_area()

  alert_list = $('#alerts').find '.alert ul'
  for message in messages
    do (message) ->
      alert_list.append '<li>' + message + '</li>'

  $('#alerts').css 'display', 'block'

# Helper method to reset the alert area
reset_alert_area = ->
  $('#alerts').find('.alert').alert 'close'
  alert_box =
    "<div class='alert alert-danger alert-dismissable' role='alert'>" +
      "<button class='close' data-dismiss='alert' aria-label='Close'>" +
      "<i class='fa fa-times'></i></button>" +
      "<ul></ul>" +
    "</div>"
  $('#alerts').append alert_box

# Are there any form errors? 
check_completeness = ->
  messages = []
  messages.push 'Workout Name cannot be empty.' if $('#wo-name').val() == ''
  messages.push 'Workout must have at least 1 exercise.' if $('#ex-list li').length == 0

  return messages

# Handle final submission of the form. Collect info from all over the form
# and make a request to the appropriate endpoint, depending on whether we're
# creating, editing, or cloning a workout.
handle_submit = ->
  messages = check_completeness()
  if messages.length != 0
    form_alert messages
    return
  
  # Collect info
  name = $('#wo-name').val()
  description = $('#description').val()
  time_limit = $('#time-limit').val()
  attempt_limit = $('#attempt-limit').val()
  policy_id = $('#policy-select').val()
  is_public = $('#is-public').is ':checked'
  published = $('#published').is ':checked'
  most_recent = $('#most_recent').is ':checked'
  removed_exercises = $('#ex-list').data 'removed-exercises'
  exercises = get_exercises()
  course_offerings = get_offerings_with_extensions()

  # Put together form data
  fd = new FormData
  fd.append 'name', name
  fd.append 'description', description
  fd.append 'time_limit', time_limit
  fd.append 'attempt_limit', attempt_limit
  fd.append 'policy_id', policy_id
  fd.append 'exercises', JSON.stringify exercises
  fd.append 'course_offerings', JSON.stringify course_offerings
  fd.append 'removed_exercises', JSON.stringify window.codeworkout.removed_exercises
  fd.append 'removed_offerings', JSON.stringify window.codeworkout.removed_offerings
  fd.append 'removed_extensions', JSON.stringify window.codeworkout.removed_extensions
  fd.append 'is_public', is_public
  fd.append 'published', published
  fd.append 'most_recent', most_recent
  fd.append 'term_id', window.codeworkout.term_id
  fd.append 'organization_id', window.codeworkout.organization_id
  fd.append 'course_id', window.codeworkout.course_id
  fd.append 'lms_assignment_id', window.codeworkout.lms_assignment_id
  # Tells the server whether this form is being submitted through LTI or not.
  # The window.codeworkout namespace was declared in the workouts/_form partial.
  if window.codeworkout.lti_launch != ''
    fd.append 'lti_launch', window.codeworkout.lti_launch

  if $('body').is '.workouts.new'
    url = '/gym/workouts'
    type = 'post'
  else if $('body').is '.workouts.edit'
    url = '/gym/workouts/' + $('h1').data('id')
    type = 'patch'
  else if $('body').is '.workouts.clone'
    url = '/gym/workouts'
    type = 'post'
  
  $.ajax
    url: url
    type: type
    data: fd
    processData: false
    contentType: false
    success: (data) ->
      window.location.href = data['url']
