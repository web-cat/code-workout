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

  # To allow reordering of exercise slots and receiving candidates dragged out of pools
  sortable = $('#ex-list').sortable
    handle: '.handle'
    connectWith: '.pool-candidates'
    placeholder: 'ui-state-highlight'
    items: '> li'
    start: (e, ui) ->
      if ui.item.hasClass('pool-slot')
        # Temporarily disable pool candidate drop targets so a pool slot cannot be dropped into a pool
        $('.pool-candidates').sortable('option', 'disabled', true)
    stop: (e, ui) ->
      $('.pool-candidates').sortable('option', 'disabled', false)
      if $('#ex-list > li').length == 0
        $('.empty-msg').css 'display', 'block'
        $('#ex-list').css 'display', 'none'
      else
        $('.empty-msg').css 'display', 'none'
        $('#ex-list').css 'display', 'block'
    receive: (event, ui) ->
      if ui.item.hasClass('candidate-item')
        ex_id = ui.item.data('id')
        name = ui.item.find('.candidate-name').text().trim()
        source_pool = ui.sender.closest('.pool-slot')
        pts = source_pool.find('.pool-points').val() || default_point_value
        data =
          id: ex_id
          exercise_workout_id: ''
          name: name
          points: pts
        new_slot = $(Mustache.render(
          $(window.codeworkout.exercise_template).filter('#exercise-template').html(),
          data
        ))
        ui.item.replaceWith(new_slot)
        update_pool_candidate_count(source_pool)
        $('.empty-msg').css 'display', 'none'
        $('#ex-list').css 'display', 'block'

  # Add a new exercise pool slot
  $('#btn-add-pool').click ->
    data =
      id: ''
      select_count: 1
      points: default_point_value
      candidate_count: 0
      has_candidates: false
      exercises: []
    template = Mustache.render(
      $(window.codeworkout.exercise_template).filter('#pool-slot-template').html(),
      data
    )
    $slot = $(template)
    $('#ex-list').append($slot)
    init_pool_candidates_sortable($slot.find('.pool-candidates'))
    $('.empty-msg').css 'display', 'none'
    $('#ex-list').css 'display', 'block'


  # Remove candidate from pool
  $('#ex-list').on 'click', '.delete-candidate', ->
    candidate = $(this).closest('.candidate-item')
    pool = candidate.closest('.pool-slot')
    candidate.remove()
    update_pool_candidate_count(pool)

  # Remove entire pool slot
  $('#ex-list').on 'click', '.delete-slot', ->
    pool = $(this).closest('.pool-slot')
    pool.remove()
    if $('#ex-list > li').length == 0
      $('.empty-msg').css 'display', 'block'
      $('#ex-list').css 'display', 'none'

  # Add an exercise from search results to the workout (always appends to main list)
  $('.search-results').on 'click', '.add-ex', ->
    ex_id = $(this).data('ex-id')
    ex_name = $(this).data('ex-name')
    name = "X#{ex_id}"
    if ex_name
      name = name + ": #{ex_name}"
    can_add = !exercise_is_in_workout(ex_id)
    if can_add
      $('.empty-msg').css 'display', 'none'
      $('#ex-list').css 'display', 'block'
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
    search_url = "/course_offerings/search_students?organization_id=#{window.codeworkout.organization_id}&course_id=#{window.codeworkout.course_id}&term_id=#{window.codeworkout.term_id}"
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
    exs = $('#ex-list > li').length
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
  pools = $('#ex-list').data 'pools'
  exercises = $('#ex-list').data 'exercises'
  if pools && pools.length > 0
    for pool in pools
      do (pool) ->
        if pool.exercises && pool.exercises.length == 1 && pool.select_count == 1 && (!pool.name || pool.name == '')
          ex = pool.exercises[0]
          name = "X#{ex.id}"
          name = name + ": #{ex.name}" if ex.name
          data =
            id: ex.id
            exercise_workout_id: ''
            name: name
            points: pool.points || default_point_value
          $('#ex-list').append(Mustache.render(
            $(window.codeworkout.exercise_template).filter('#exercise-template').html(),
            data
          ))
        else
          items = []
          if pool.exercises
            for ex in pool.exercises
              name = "X#{ex.id}"
              name = name + ": #{ex.name}" if ex.name
              items.push { id: ex.id, name: name }
          data =
            id: pool.id || ''
            select_count: pool.select_count || 1
            points: pool.points || default_point_value
            candidate_count: items.length
            has_candidates: items.length > 0
            exercises: items
          $('#ex-list').append(Mustache.render(
            $(window.codeworkout.exercise_template).filter('#pool-slot-template').html(),
            data
          ))
    init_pool_candidates_sortable($('.pool-candidates'))
  else if exercises && exercises.length > 0
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
  $('#ex-list').removeData 'pools'
  $('#ex-list').removeData 'exercises'

init_pool_candidates_sortable = (elements) ->
  elements.sortable
    connectWith: '#ex-list, .pool-candidates'
    handle: '.candidate-handle, .handle'
    placeholder: 'ui-state-highlight'
    items: '> li'
    receive: (event, ui) ->
      if ui.item.hasClass('pool-slot')
        $(ui.sender).sortable('cancel')
        return false

      ex_id = ui.item.data('id')
      target_pool = $(this).closest('.pool-slot')
      # Prevent duplicate candidates in the same pool
      if target_pool.find(".candidate-item[data-id=#{ex_id}]").not(ui.item).length > 0
        $(ui.sender).sortable('cancel')
        form_alert(["Exercise is already a candidate in this exercise pool."])
        return false

      if ui.item.hasClass('single-slot')
        name = ui.item.find('.exercise-name').text().trim()
        cand_data =
          id: ex_id
          name: name
        cand_template = $(Mustache.render(
          $(window.codeworkout.exercise_template).filter('#pool-candidate-template').html(),
          cand_data
        ))
        ui.item.replaceWith(cand_template)
        update_pool_candidate_count(target_pool)
        if $('#ex-list > li').length == 0
          $('.empty-msg').css 'display', 'block'
          $('#ex-list').css 'display', 'none'
      else if ui.item.hasClass('candidate-item')
        update_pool_candidate_count(target_pool)
    stop: (e, ui) ->
      if ui.item && ui.item.parent().length
        update_pool_candidate_count(ui.item.closest('.pool-slot'))
      if ui.sender && ui.sender.length
        update_pool_candidate_count(ui.sender.closest('.pool-slot'))

update_pool_candidate_count = (pool) ->
  return unless pool && pool.length
  candidates = pool.find('.pool-candidates .candidate-item')
  count = candidates.length
  pool.find('.pool-size-label').text("of #{count}")
  empty_msg = pool.find('.empty-candidates-msg')
  if count == 0
    empty_msg.show()
  else
    empty_msg.hide()

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

get_pools = ->
  pools = []
  $('#ex-list > li').each (index) ->
    $slot = $(this)
    if $slot.hasClass('pool-slot')
      pool_id = $slot.data('pool-id') || null
      select_count = parseInt($slot.find('.select-count').val() || '1')
      points = parseFloat($slot.find('.pool-points').val() || '0')
      cand_ids = []
      $slot.find('.pool-candidates .candidate-item').each ->
        cand_ids.push $(this).data('id')
      pools.push
        id: pool_id
        position: index + 1
        select_count: select_count
        points: points
        exercise_ids: cand_ids
    else
      # Single-slot exercise
      ex_id = $slot.data('id')
      points = parseFloat($slot.find('.points').val() || '0')
      pools.push
        position: index + 1
        select_count: 1
        points: points
        exercise_ids: [ex_id]
  return pools

get_exercises = ->
  exercises = []
  $('#ex-list > li').each ->
    $slot = $(this)
    if $slot.hasClass('pool-slot')
      pts = $slot.find('.pool-points').val() || '0'
      $slot.find('.pool-candidates .candidate-item').each ->
        exercises.push { id: $(this).data('id'), points: pts }
    else
      ex_id = $slot.data('id')
      pts = $slot.find('.points').val() || '0'
      exercises.push { id: ex_id, points: pts }
  return exercises

exercise_is_in_workout = (ex_id) ->
  found = false
  $('#ex-list .single-slot, #ex-list .candidate-item').each ->
    if $(this).data('id') == ex_id
      found = true
  return found

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
  messages.push 'Workout must have at least 1 exercise.' if $('#ex-list > li').length == 0
  $('#ex-list > li.pool-slot').each (index) ->
    candidates = $(this).find('.candidate-item').length
    select_count = parseInt($(this).find('.select-count').val() || '0')
    if candidates == 0
      messages.push "Exercise pool in slot #{index + 1} has no exercises. Please add exercises or remove the pool."
    else if select_count < 1
      messages.push "Exercise pool in slot #{index + 1} must draw at least 1 exercise."
    else if select_count > candidates
      messages.push "Exercise pool in slot #{index + 1} cannot draw #{select_count} exercises from #{candidates} available candidates."
  if $('#date-yaml').length > 0
    yaml_text = $('#date-yaml').val() || ''
    matches = yaml_text.match(/(?:workout_attempts|workout_attempt_limit|attempts)\s*:\s*([0-9]*)/g)
    if matches
      has_multiple = false
      for m in matches
        val_str = m.replace(/.*:\s*/, '').trim()
        val = parseInt(val_str, 10)
        if isNaN(val) || val <= 0 || val > 1
          has_multiple = true
          break
      if has_multiple
        time_limit_val = parseFloat($('#time-limit').val())
        if isNaN(time_limit_val) || time_limit_val <= 0
          messages.push 'Time limit must be greater than 0 when multiple workout attempts are allowed in YAML.'
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
    return
  fd.append 'policy', JSON.stringify policy
  
  fd.append 'pools', JSON.stringify get_pools()
  fd.append 'exercises', JSON.stringify get_exercises()
  fd.append 'date_yaml', $('#date-yaml').val() || ''
  fd.append 'removed_exercises', JSON.stringify window.codeworkout.removed_exercises
  
  fd.append 'is_public', $('#is-public').is ':checked'
  fd.append 'published', $('#published').is ':checked'
  
  exercise_score_el = $('#exercise-score-to-keep, #exercise_score_to_keep, #most-recent, #most_recent')
  if exercise_score_el.length
    if exercise_score_el.is('select')
      fd.append 'exercise_score_to_keep', exercise_score_el.val()
    else
      fd.append 'exercise_score_to_keep', if exercise_score_el.is(':checked') then 'latest' else 'highest'
  
  fd.append 'term_id', window.codeworkout.term_id
  fd.append 'organization_id', window.codeworkout.organization_id
  fd.append 'course_id', window.codeworkout.course_id
  fd.append 'lms_assignment_id', window.codeworkout.lms_assignment_id
  fd.append 'lti_assignment_id', window.codeworkout.lti_assignment_id
  
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
