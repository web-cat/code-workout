$(document).ready ->
  $('#term_id').change ->
    window.location.href = '?term_id=' + $('#term_id').val()

  org_autocomplete = $('#organization').autocomplete
    minLength: 2
    autoFocus: true
    source: '/organizations/search'
    response: (event, ui) ->
      ui.content.push({ name: '+ Add new organization' })
    select: (event, ui) ->
      if ui.item.slug?
        $('#organization').val ui.item.name
        $('#organization').data 'org-id', ui.item.slug
        setup_course_fields ui.item.slug
      else
        $('#organization').removeData 'org-id'
        $('.new-org').css 'display', 'block'
        $('#organization').autocomplete 'disable'
        $('#btn-org').text 'Cancel'
        $('#btn-org').css 'display', 'block'
      return false

  org_autocomplete.data('ui-autocomplete')._renderItem = (ul, item) ->
    return $('<li class="list-group-item"></li>')
      .append(item.name)
      .appendTo(ul)

  org_autocomplete.data('ui-autocomplete')._renderMenu = (ul, items) ->
    that = this
    $.each items, (index, item) ->
      that._renderItemData(ul, item)
    $(ul).addClass 'list-group'

  $('#organization').on 'blur', ->
    val = $('#organization').val()
    selection = $('#organization').data 'org-id'
    if !selection?
      placeholder = get_abbr_suggestion val

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
          return true
        else
          uniqueness.addClass 'fa fa-times-circle text-danger'
          org_name = data['name']
          msg = "Sorry, that abbreviation is being used by #{org_name}"
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
          setup_course_fields data['id']

setup_course_fields = (id)->
  $('.org-setup :input').attr 'disabled', true
  $('.course-setup').css 'display', 'block'
  course_autocomplete = $('#course').autocomplete
    minLength: 2
    autoFocus: true
    source: '/courses/' + id + '/search'
    response: (event, ui) ->
      ui.content.push({ name: '+ Add new course' })
    select: (event, ui) ->
      if ui.item.slug?
        $('#course').val ui.item.name
        $('#course').data 'course-id', ui.item.slug
      else
        $('#course').removeData 'org-id'
        $('#course').autocomplete 'disable'
      return false

  course_autocomplete.data('ui-autocomplete')._renderItem = (ul, item) ->
    return $('<li class="list-group-item"></li>')
      .append(item.name)
      .appendTo(ul)

  course_autocomplete.data('ui-autocomplete')._renderMenu = (ul, items) ->
    that = this
    $.each items, (index, item) ->
      that._renderItemData(ul, item)
    $(ul).addClass 'list-group'
