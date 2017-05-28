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

$('.courses.show').ready ->
  $('a[data-toggle="tab"]').on 'shown.bs.tab', (e) ->
    tab_id = $(e.target).attr('href')
    tab_id = tab_id.slice(1, tab_id.length)
    needs_update = $('#' + tab_id).data 'needs-update'
    if needs_update? and needs_update == true
      requestUpdate(tab_id)

    if tab_id == ROSTER_TAB
      $("\##{tab_id}").on 'requestUpdate', ->
        $("\##{tab_id}").html("<div class='col-xs-offset-6'><i class='fa fa-spin fa-2x'/></div>")
        requestUpdate(tab_id)

$('.courses.privileged_users').ready ->
  console.log 'here'
