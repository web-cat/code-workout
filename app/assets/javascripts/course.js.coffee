$('.courses.show').ready ->
  $('a[data-toggle="tab"]').on 'shown.bs.tab', (e) ->
    tab_id = $(e.target).attr('href')
    tab_id = tab_id.slice(1, tab_id.length)
    needs_update = $('#' + tab_id).data 'needs-update'
    if needs_update? and needs_update == true      # can't use .is(':empty') because some browsers look at line breaks as elements
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

$('.courses.privileged_users').ready ->
  console.log 'here'
  setup_autocomplete()

setup_autocomplete = ->
  autocomplete = $('#user').autocomplete
    minLength: 2
    autoFocus: true
    url: $('#user').data 'url'
    select: (event, ui) ->
      console.log ui.item
