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
