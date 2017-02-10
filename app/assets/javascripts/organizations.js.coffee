$(document).ready ->
  $('#term_id').change ->
    window.location.href = '?term_id=' + $('#term_id').val()

  autocomplete = $('#organization').autocomplete
    minLength: 2
    autoFocus: true
    source: '/organizations/search'
    response: (event, ui) ->
      ui.content.push({ name: '+ Add new organization' })
    select: (event, ui) ->
      if ui.item.slug?
        $('#organization').val ui.item.name
        $('#organization').data 'org-id', ui.item.slug
        $('#btn-org').text 'Continue'
        $('#btn-org').css 'display', 'block'
      else
        $('#organization').removeData 'org-id'
        $('.new-org').css 'display', 'block'
        $('#organization').autocomplete 'disable'
        $('#btn-org').text 'Cancel'
        $('#btn-org').css 'display', 'block'
      return false

  autocomplete.data('ui-autocomplete')._renderItem = (ul, item) ->
    return $('<li class="list-group-item"></li>')
      .append(item.name)
      .appendTo(ul)

  autocomplete.data('ui-autocomplete')._renderMenu = (ul, items) ->
    that = this
    $.each items, (index, item) ->
      that._renderItemData(ul, item)
    $(ul).addClass 'list-group'

  $('#organization').on 'blur', ->
    val = $('#organization').val()
    selection = $('#organization').data 'org-id'
    if !selection?
      placeholder = get_abbr_suggestion val
      $('#abbr').attr 'placeholder', "suggested: #{placeholder}"

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

  $('#btn-unique').on 'click', ->
    term = $('#abbr').val()
    validate_slug term

  $('#btn-submit-org').on 'click', ->
    validate()

get_abbr_suggestion = (org_name)->
  lowers = ['the', 'and', 'for', 'at', 'in', 'of']
  org_name = org_name.toLowerCase()
  console.log "Full lower case: #{org_name}"
  replace_func = (txt)->
    if txt.trim() in lowers
      return txt.toLowerCase()
    else
      return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()
  title_case = org_name.replace(/([^\W_]+[^\s-]*) */g, replace_func)
  matches = title_case.match /([A-Z\-])+/g
  acronym = matches.join ''
  return acronym

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
        if !data
          uniqueness.addClass 'fa fa-check-circle text-success'
          return true
        else
          uniqueness.addClass 'fa fa-times-circle text-danger'
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
