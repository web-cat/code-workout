ORGANIZATION = '#organization'
COURSE = '#course'

$(document).ready ->
  $('#term_id').change ->
    window.location.href = '?term_id=' + $('#term_id').val()

  setup_autocomplete '/organizations/search', ORGANIZATION

  $('#organization').on 'blur', ->
    val = $('#organization').val()
    selection = $('#organization').data 'org-id'
    if !selection?
      get_abbr_suggestion val

  $('#btn-org').on 'click', ->
    if $(this).text() == 'Cancel'
      $('.new-org').css 'display', 'none'
      $('#organization').val ''
      $('#organization').autocomplete 'enable'
    else if $(this).text() == 'Continue'
      selection = $('#organization').data 'org-id'
      window.location = '/courses/' + selection

  $('#btn-add').on 'click', ->
    name = $('#organization').val()
    validate_name name

  keyup_thread = null
  $('#abbr').keyup ->
    clearTimeout keyup_thread
    keyup_thread = setTimeout ->
      term = $('#abbr').val()
      if term == ''
        $('#org-hint').text ''
      validate_slug term.toLowerCase()
    , 1000

  $('#btn-submit-org').on 'click', ->
    handle_submit_organization()

get_abbr_suggestion = (org_name)->
  lowers = ['the', 'and', 'for', 'at', 'in', 'of']

  org_name = org_name.toLowerCase()
  replace_func = (txt)->
    if txt.trim() in lowers
      return txt.toLowerCase()
    else
      return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()
  title_case = org_name.replace(/([^\W_]+[^\s-]*) */g, replace_func)
  words = title_case.split ' '
  matches = title_case.match /([A-Z\-])+/g
  if matches?
    acronym = matches.join ''
    $.ajax
      url: '/organizations/search'
      type: 'get'
      dataType: 'json'
      data: { suggestion: true, term: acronym.toLowerCase() }
      success: (data)->
        if data.length == 0
          $('#abbr').attr 'placeholder', "suggested: #{acronym}"
        else
          val = data[data.length - 1].name
          split = val.split ''
          ind = split[split.length - 1]
          if isNaN(ind)
            acronym = acronym + "1"
            $('#abbr').attr 'placeholder', "suggested: #{acronym}"
          else
            ind = parseInt(int) + 1
            acronym = acronym + "" + ind
            $('#abbr').attr 'placeholder', "suggested: #{acronym}"

validate_slug = (term)->
  uniqueness = $('#uniqueness')
  uniqueness.removeClass()
  if term == ''
    uniqueness.addClass 'fa fa-times-circle text-danger'
    return false
  else
    uniqueness.addClass 'fa fa-spinner'
    $.ajax
      url: '/organizations/search'
      type: 'get'
      dataType: 'json'
      data: { slug: true, term: term }
      success: (data) ->
        uniqueness.removeClass 'fa-spinner'
        if !data?
          uniqueness.addClass 'fa fa-check-circle text-success'
          $('#org-hint').text ''
          return true
        else
          uniqueness.addClass 'fa fa-times-circle text-danger'
          org_name = data['name']
          msg = "Sorry, that abbreviation is being used by #{org_name}."
          $('#org-hint').text msg
          return false

validate_name = (name)->
  if name == ''
    # add the class to trigger the animation
    # then remove it, so that the animation can re-run next time
    $('#hint').addClass 'shake'
    setTimeout ->
      $('#hint').removeClass 'shake'
    , 1000
    return false
  else
    return true

validate = ->
  valid = validate_slug($('#abbr').val()) &&
    validate_name($('#organization').val())

setup_autocomplete = (url, field_id)->
  if field_id == COURSE
    $('.org-setup :input').attr 'disabled', true
    $('.course-setup').css 'display', 'block'

  autocomplete = $(field_id).autocomplete
    minLength: 2
    autoFocus: true
    source: url
    response: (event, ui) ->
      ui.content.push({ name: '+ Add new' })
    select: (event, ui)->
      return handle_select_from_autocomplete event, ui, field_id

  autocomplete.data('ui-autocomplete')._renderItem = (ul, items)->
    return $('<li class="list-group-item"></li>')
      .append(item.name)
      .appendTo(ul)

  autocomplete.data('ui-autocomplete')._renderItem = (ul, item) ->
    return $('<li class="list-group-item"></li>')
      .append(item.name)
      .appendTo(ul)

# Handle the select event from either autocomplete (organization or course), since
# they have mostly similar interactions.
# field_id will either be '#organization' or '#course' (see constants at line 1-2).
handle_select_from_autocomplete = (event, ui, field_id)->
  field = $(field_id)
  if field_id == ORGANIZATION
    data = 'org-id'
    additional_fields = '.new-org'
  else if field_id == COURSE
    data = 'course-id'
    additional_fields = '.new-course'

  if ui.item.slug?
    field.val ui.item.name
    field.data data, ui.item.slug
    if field_id == ORGANIZATION
      setup_autocomplete '/courses/' + ui.item.slug + '/search', COURSE
  else
    field.removeData data
    field.autocomplete 'disable'
    $(additional_fields).css 'display', 'block'
    if field_id == ORGANIZATION
      val = field.val()
      get_abbr_suggestion val
  return false

handle_submit_organization = ->
  valid = validate()
  if valid
    name = $('#organization').val()
    abbr = $('#abbr').val()
    $.ajax
      url: '/organizations/'
      type: 'post'
      data: { name: name, abbreviation: abbr }
      dataType: 'json'
      success: (data)->
        if data['success']
          setup_autocomplete '/courses/' + data['id'] + '/search', COURSE
