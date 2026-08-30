default_point_value = 1
searchable = null

$('.workouts.new, .workouts.edit, .workouts.clone').ready ->
  window.codeworkout ?= {}
  window.codeworkout.removed_exercises = []
  
  # Store initial state for removal confirmation
  if $('#date-yaml').length
    $('#date-yaml').data('initial-sections', ($('#date-yaml').val().match(/section:/g) || []).length)
  
  # Track last cursor position in textarea
  $('#date-yaml').on 'blur focus click input', ->
    $(this).data('last-cursor', this.selectionStart)

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

  # From the modal showing available course offerings, add the
  # selected one to the YAML text area before extensions:
  $('#course-offerings').on 'click', 'a', ->
    label = $(this).text().trim()
    new_section = "  - section: #{label}\n    due: \n    from: \n    until: \n"
    
    textarea = $('#date-yaml')
    content = textarea.val()
    ext_pos = content.indexOf('extensions:')
    
    if ext_pos == -1
      new_content = content.trim() + "\n" + new_section
    else
      new_content = content.substring(0, ext_pos) + new_section + content.substring(ext_pos)
    
    textarea.val(new_content)
    $(this).remove()
    $('#offerings-modal').modal 'hide'
    textarea.focus()
    textarea.trigger('change')

  # Show the StudentSearch modal
  $('#add-student-btn').on 'click', ->
    textarea = $('#date-yaml')
    cursor = textarea.data('last-cursor')
    if typeof cursor == 'undefined'
      show_toolbar_tooltip($(this), "Select an insertion point first")
      return

    # Lock the cursor position
    textarea.data('locked-cursor', cursor)
    
    $('#student-search-modal').modal('show')
    search_url = "/gym/workouts/search_students?organization_id=#{window.codeworkout.organization_id}&course_id=#{window.codeworkout.course_id}&term_id=#{window.codeworkout.term_id}"
    searchable = $('.searchable').StudentSearch
      course_offering_display: 'any section'
      course_offering_id: 0
      search_url: search_url

  # When a student is selected, insert them at the locked cursor position
  $('.searchable').on 'studentSelect', (e) ->
    insert_at_cursor(e.student_display, true)
    $('#student-search-modal').modal('hide')

  # Initialize flatpickr on the "Select Date" button
  $('#select-date-btn').flatpickr
    enableTime: true
    noCalendar: false
    dateFormat: "Y-m-d h:i K"
    time_24hr: false
    disableMobile: "true"
    onOpen: (selectedDates, dateStr, instance) ->
      textarea = $('#date-yaml')
      cursor = textarea.data('last-cursor')
      if typeof cursor == 'undefined'
        instance.close()
        show_toolbar_tooltip($('#select-date-btn'), "Select an insertion point first")
        return
      # Lock the cursor position
      textarea.data('locked-cursor', cursor)
    onReady: (selectedDates, dateStr, instance) ->
      # Add an "Insert" button to the picker
      $btn = $('<div class="flatpickr-insert-btn" style="text-align: center; padding: 5px; border-top: 1px solid #eee; cursor: pointer; font-weight: bold; color: #3da2b4;">Insert</div>')
      $btn.on 'click', -> instance.close()
      $(instance.calendarContainer).append($btn)
    onClose: (selectedDates, dateStr, instance) ->
      if selectedDates.length
        insert_at_cursor(dateStr, true)

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

init = ->
  description = $('textarea#description').data 'value'
  $('textarea#description').val description
  init_templates()

init_templates = ->
  $.get window.codeworkout.exercise_template_path, (template, textStatus, jqXHr) ->
    window.codeworkout.exercise_template = template
    if $('body').is('.workouts.edit') || $('body').is('.workouts.clone')
      init_exercises()

init_exercises = ->
  exercises = $('#ex-list').data 'exercises'
  if exercises
    for exercise in exercises
      do (exercise) ->
        name = "X#{exercise.id}"
        if exercise.name
          name = name + ": #{exercise.name}"

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

insert_at_cursor = (val, use_locked = false) ->
  textarea = $('#date-yaml')
  if use_locked
    pos = textarea.data('locked-cursor')
  else
    pos = textarea.data('last-cursor')
    
  if typeof pos == 'undefined'
    pos = textarea.val().length
  
  content = textarea.val()
  new_content = content.substring(0, pos) + val + content.substring(pos)
  textarea.val(new_content)
  
  # Update cursor position and focus
  new_pos = pos + val.length
  textarea[0].selectionStart = textarea[0].selectionEnd = new_pos
  textarea.data('last-cursor', new_pos)
  textarea.focus()
  textarea.trigger('change')

show_toolbar_tooltip = (element, message) ->
  element.popover({
    content: message,
    placement: 'top',
    trigger: 'manual',
    container: 'body',
    template: '<div class="popover" role="tooltip" style="z-index: 10000;"><div class="arrow"></div><div class="popover-content" style="padding: 5px 10px; font-size: 12px; color: #fff; background: #d9534f; border-radius: 4px;"></div></div>'
  }).popover('show')
  
  # Hide after 2 seconds
  setTimeout (-> element.popover('destroy')), 2000

close_slider = ->
  if $('.sidebar').hasClass('slider') && $('.toggle-slider').attr('data-is-open')
    $('.toggle-slider').click()
    $('#search-terms').val('')
    $('.search-results').empty()

get_exercises = ->
  exs = $('#ex-list li')
  exercises = []
  i = 0
  while i < exs.length
    ex_id = $(exs[i]).data('id')
    ex_points = $(exs[i]).find('.points').val()
    ex_points = '0' if ex_points == ''
    ex_obj = { id: ex_id, points: ex_points }
    exercises.push(ex_obj)
    i++
  return exercises

exercise_is_in_workout = (ex_id) ->
  for exercise in get_exercises() when exercise['id'] is ex_id
    return true
  return false

form_alert = (messages) ->
  reset_alert_area()
  alert_list = $('#alerts').find '.alert ul'
  for message in messages
    alert_list.append '<li>' + message + '</li>'
  $('#alerts').css 'display', 'block'
  # Scroll to alerts
  $('html, body').animate({ scrollTop: $('#alerts').offset().top - 20 }, 300)

reset_alert_area = ->
  $('#alerts').find('.alert').alert 'close'
  alert_box =
    "<div class='alert alert-danger alert-dismissable' role='alert'>" +
      "<button class='close' data-dismiss='alert' aria-label='Close'>" +
      "<i class='fa fa-times'></i></button>" +
      "<ul></ul>" +
    "</div>"
  $('#alerts').append alert_box

check_completeness = ->
  messages = []
  messages.push 'Workout Name cannot be empty.' if $('#wo-name').val() == ''
  messages.push 'Workout must have at least 1 exercise.' if $('#ex-list li').length == 0
  return messages

handle_submit = ->
  messages = check_completeness()
  if messages.length != 0
    form_alert messages
    return

  if $('#date-yaml').length
    initial_sections = $('#date-yaml').data('initial-sections') || 0
    current_sections = ($('#date-yaml').val().match(/section:/g) || []).length
    if current_sections < initial_sections
      if !confirm("You have removed one or more course offerings. This will delete all student scores for those offerings. Are you sure?")
        return

  # Collect info
  fd = new FormData
  fd.append 'name', $('#wo-name').val()
  fd.append 'description', $('#description').val()
  fd.append 'time_limit', $('#time-limit').val()
  fd.append 'attempt_limit', $('#attempt-limit').val()
  
  policy = {}
  $('.policy-checkbox').each ->
    attr = $(this).attr('data-attribute')
    policy[attr] = $(this).is(':checked') if attr
  fd.append 'policy', JSON.stringify policy
  
  fd.append 'exercises', JSON.stringify get_exercises()
  fd.append 'date_yaml', $('#date-yaml').val()
  fd.append 'removed_exercises', JSON.stringify window.codeworkout.removed_exercises
  
  fd.append 'is_public', $('#is-public').is ':checked'
  fd.append 'published', $('#published').is ':checked'
  fd.append 'most_recent', $('#most_recent').is ':checked'
  
  fd.append 'term_id', window.codeworkout.term_id
  fd.append 'organization_id', window.codeworkout.organization_id
  fd.append 'course_id', window.codeworkout.course_id
  fd.append 'lms_assignment_id', window.codeworkout.lms_assignment_id
  
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
    error: (xhr) ->
      errorMsg = xhr.responseJSON?.error || xhr.responseText || 'An error occurred'
      form_alert ["Error: #{errorMsg}"]
