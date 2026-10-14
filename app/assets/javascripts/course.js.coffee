##########################
#    COURSE SHOW PAGE    #
##########################
ROSTER_TAB = 'tab_roster'

requestUpdate = (tab_id) ->
  url = window.location.href
  split = url.split('/').filter((entry) -> return entry.trim() != '')
  term_id = split[split.length - 1]
  course_id = split[split.length - 2]
  organization_id = split[split.length - 3]

  $.ajax
    url: '/courses/' + organization_id + '/' + course_id + '/' + term_id + '/tab_content/' + tab_id
    type: 'get'
    dataType: 'script'
    cache: true
    success: (data) ->
      $('#' + tab_id).data 'needs-update', 'false'

$('#request-privileged-access').on 'click', ->
  $('.privileged-access').html('<i class="fa fa-spinner fa-spin"></i>')

$('.courses.show').ready ->
  $('a[data-toggle="tab"]').on 'shown.bs.tab', (e) ->
    tab_id = $(e.target).attr('href')
    tab_id = tab_id.slice(1, tab_id.length)
    needs_update = $('#' + tab_id).data 'needs-update'
    if needs_update? and needs_update == true
      requestUpdate(tab_id)

    if tab_id == ROSTER_TAB
      $("\##{ROSTER_TAB}").on 'requestUpdate', ->
        $("\##{ROSTER_TAB}").html("<div class='col-xs-offset-6'><i class='fa fa-spin fa-2x'/></div>")
        requestUpdate(ROSTER_TAB)
      $("\##{ROSTER_TAB}").on 'click', '.unenroll', ->
        row = $(this).closest 'tr'
        id = row.data('course-enrollment')
        user_name = row.data('user-name')
        user_id = row.data('user-id')
        course_offering = row.closest('table').find('.course-offering-label').text().trim()
        confirmed = confirm("Are you sure you want to unenroll #{user_name} from the #{course_offering} section?")
        if confirmed
          request_remove_enrollment(id, row)

request_remove_enrollment = (id, row) ->
  $.ajax
    url: "/course_enrollments/#{id}"
    type: 'delete'
    dataType: 'json'
    success: (data) ->
      row.fadeOut()

##########################
#    GRADEBOOK FILTERS   #
##########################

applyGradebookFilters = ($section) ->
  studentQuery = ($section.find('.gradebook-filter-student').val() || '').toLowerCase().trim()
  assignmentQuery = ($section.find('.gradebook-filter-assignment').val() || '').toLowerCase().trim()
  $table = $section.find('.gradebook-table')

  # Filter student rows
  $table.find('tbody tr').each ->
    $row = $(this)
    $studentCell = $row.find('.col-student')
    studentName = ($studentCell.data('student-name') || '').toLowerCase()
    studentEmail = ($studentCell.data('student-email') || '').toLowerCase()
    studentText = $studentCell.text().toLowerCase()

    matchesStudent = !studentQuery ||
      studentName.indexOf(studentQuery) != -1 ||
      studentEmail.indexOf(studentQuery) != -1 ||
      studentText.indexOf(studentQuery) != -1

    $row.toggle(matchesStudent)

  # Filter assignment columns
  $table.find('thead th.col-workout').each ->
    $th = $(this)
    workoutName = ($th.data('workout-name') || $th.text()).toLowerCase()
    wktoId = $th.data('wkto-id')
    matchesAssignment = !assignmentQuery || workoutName.indexOf(assignmentQuery) != -1

    $table.find(".col-wkto-#{wktoId}").toggle(matchesAssignment)

$(document).on 'input search', '.gradebook-filter-student, .gradebook-filter-assignment', ->
  $section = $(this).closest('.gradebook-section')
  applyGradebookFilters($section)

$(document).on 'click', '.gradebook-clear-input', ->
  $inputGroup = $(this).closest('.input-group')
  $input = $inputGroup.find('input')
  $input.val('')
  $section = $(this).closest('.gradebook-section')
  applyGradebookFilters($section)
  $input.focus()

$(document).on 'click', '.gradebook-filter-reset', ->
  $section = $(this).closest('.gradebook-section')
  $section.find('.gradebook-filter-student').val('')
  $section.find('.gradebook-filter-assignment').val('')
  applyGradebookFilters($section)

$(document).on 'keydown', '.gradebook-filter-student, .gradebook-filter-assignment', (e) ->
  if e.which == 13
    e.preventDefault()

##########################
#    WORKOUT FILTERS     #
##########################

updateWorkoutStateFilterBtnText = (checkedStates) ->
  $btn = $('#workout-state-filter-btn .workout-state-btn-text')
  return unless $btn.length

  if !checkedStates || checkedStates.length == 0
    $btn.text('State: All')
  else if checkedStates.length == 1
    labelMap =
      open: 'Open'
      past_due: 'Past due'
      past: 'Past'
      future: 'Future'
      published: 'Published'
      unpublished: 'Not published'
    $btn.text("State: #{labelMap[checkedStates[0]] || checkedStates[0]}")
  else if checkedStates.length == 2
    labelMap =
      open: 'Open'
      past_due: 'Past due'
      past: 'Past'
      future: 'Future'
      published: 'Published'
      unpublished: 'Not published'
    $btn.text("State: #{labelMap[checkedStates[0]] || checkedStates[0]}, #{labelMap[checkedStates[1]] || checkedStates[1]}")
  else
    $btn.text("State: (#{checkedStates.length} selected)")

applyWorkoutFilters = ->
  query = ($('.workout-filter-name').val() || '').toLowerCase().trim()

  checkedStates = []
  $('.workout-state-checkbox:checked').each ->
    checkedStates.push($(this).val())

  dateStates = (s for s in checkedStates when s in ['open', 'past_due', 'past', 'future'])
  pubStates = (s for s in checkedStates when s in ['published', 'unpublished'])

  $cards = $('.workouts-list .workout-card')
  visibleCount = 0

  $cards.each ->
    $card = $(this)
    wName = ($card.data('workout-name') || '').toString().toLowerCase()
    cardText = $card.find('.title').text().toLowerCase()

    # Name filter
    matchesName = !query || wName.indexOf(query) != -1 || cardText.indexOf(query) != -1

    # Date state filter
    matchesDate = true
    if dateStates.length > 0
      matchesDate = false
      for s in dateStates
        if s == 'open' and String($card.data('is-open')) == 'true'
          matchesDate = true
          break
        if s == 'past_due' and String($card.data('is-past-due')) == 'true'
          matchesDate = true
          break
        if s == 'past' and String($card.data('is-past')) == 'true'
          matchesDate = true
          break
        if s == 'future' and String($card.data('is-future')) == 'true'
          matchesDate = true
          break

    # Publication state filter
    matchesPub = true
    if pubStates.length > 0
      matchesPub = false
      for s in pubStates
        if s == 'published' and String($card.data('is-published')) == 'true'
          matchesPub = true
          break
        if s == 'unpublished' and String($card.data('is-unpublished')) == 'true'
          matchesPub = true
          break

    matches = matchesName && matchesDate && matchesPub
    $card.toggle(matches)
    if matches
      visibleCount += 1

  if $cards.length > 0 && visibleCount == 0
    $('.workout-no-matches').show()
  else
    $('.workout-no-matches').hide()

  updateWorkoutStateFilterBtnText(checkedStates)

applyWorkoutSort = ->
  sortMode = $('.workout-sort-select').val() || 'due-asc'
  $container = $('.workouts-list')
  $cards = $container.children('.workout-card').get()
  return unless $cards.length

  $cards.sort (a, b) ->
    $a = $(a)
    $b = $(b)
    nameA = ($a.data('workout-name') || '').toString()
    nameB = ($b.data('workout-name') || '').toString()
    dueA = Number($a.data('due-date'))
    dueB = Number($b.data('due-date'))
    openA = Number($a.data('opening-date'))
    openB = Number($b.data('opening-date'))

    switch sortMode
      when 'name-asc'
        nameA.localeCompare(nameB)
      when 'name-desc'
        nameB.localeCompare(nameA)
      when 'due-desc'
        if dueA == 9999999999 && dueB != 9999999999
          1
        else if dueB == 9999999999 && dueA != 9999999999
          -1
        else if dueA != dueB
          dueB - dueA
        else
          nameA.localeCompare(nameB)
      when 'open-asc'
        if openA != openB
          openA - openB
        else
          nameA.localeCompare(nameB)
      when 'open-desc'
        if openA == 9999999999 && openB != 9999999999
          1
        else if openB == 9999999999 && openA != 9999999999
          -1
        else if openA != openB
          openB - openA
        else
          nameA.localeCompare(nameB)
      else # due-asc (default)
        if dueA != dueB
          dueA - dueB
        else
          nameA.localeCompare(nameB)

  $.each $cards, (idx, card) ->
    $container.append(card)

$(document).on 'input search', '.workout-filter-name', ->
  applyWorkoutFilters()

$(document).on 'keydown', '.workout-filter-name', (e) ->
  if e.which == 13
    e.preventDefault()

$(document).on 'click', '.workout-clear-name', ->
  $input = $(this).closest('.input-group').find('.workout-filter-name')
  $input.val('')
  applyWorkoutFilters()
  $input.focus()

$(document).on 'click', '.workout-state-option', (e) ->
  e.preventDefault()
  e.stopPropagation()
  $cb = $(this).find('.workout-state-checkbox')
  $cb.prop('checked', !$cb.prop('checked'))
  applyWorkoutFilters()

$(document).on 'click', '.workout-state-checkbox', (e) ->
  e.stopPropagation()
  applyWorkoutFilters()

$(document).on 'click', '.workout-state-menu', (e) ->
  unless $(e.target).closest('.workout-state-reset').length
    e.stopPropagation()

$(document).on 'click', '.workout-state-reset', (e) ->
  e.preventDefault()
  $('.workout-state-checkbox').prop('checked', false)
  applyWorkoutFilters()

$(document).on 'change', '.workout-sort-select', ->
  applyWorkoutSort()

##########################
#    PRIVILEGED USERS    #
##########################

$('.courses.privileged_users').ready ->
  setup_autocomplete()

setup_autocomplete = ->
  user_group_id = $('h1').data('user-group-id')
  url = "/user_groups/#{user_group_id}/members?notin=true"
  autocomplete = $('#privileged-user').autocomplete
    minLength: 2
    autoFocus: true
    source: url
    select: (event, ui) ->
      handle_autocomplete_select(event, ui)

  autocomplete.data('ui-autocomplete')._renderItem = (ul, item) ->
    display = "#{item.first_name} #{item.last_name} (#{item.email})"
    return $('<li class="list-group-item"></li>')
      .append(display)
      .appendTo(ul)

handle_autocomplete_select = (event, ui) ->
  user_id = ui.item.id
  user_group_id = $('h1').data('user-group-id')
  $.ajax
    url: "/user_groups/#{user_group_id}/add_user/#{user_id}"
    type: 'post'
    dataType: 'json'
    success: (data) ->
      if data.error?
        alert(data['error'])
      else
        userlist = $('.privileged-user-list > tbody')
        row = $("<tr data-user-id=#{data.id}><td><a href=#{data.url}>#{data.name}</a></td></tr>")
        row.prependTo(userlist)
