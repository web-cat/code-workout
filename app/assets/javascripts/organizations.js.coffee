$(document).ready ->
  $('#term_id').change ->
    window.location.href = '?term_id=' + $('#term_id').val()

  autcomplete = $('#organization').autocomplete
    minLength: 2
    source: '/organizations/search'
    response: (event, ui) ->
      ui.content.unshift({ name: '+ Add new organization' })
    focus: (event, ui) ->
      if ui.item.slug?
        $('#organization').val ui.item.name
        $('#organization').data 'org-id', ui.item.slug
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

  autcomplete.data('ui-autocomplete')._renderItem = (ul, item) ->
    return $('<li class="list-group-item"></li>')
      .append(item.name)
      .appendTo(ul)

  autcomplete.data('ui-autocomplete')._renderMenu = (ul, items) ->
    that = this
    $.each items, (index, item) ->
      that._renderItemData(ul, item)
    $(ul).addClass 'list-group'

  $('#btn-org').on 'click', ->
    if $(this).text() == 'Cancel'
      $('.new-org').css 'display', 'none'
      $('#organization').autocomplete 'enable'
    else if $(this).text() == 'Continue'
      selection = $('#organization').data 'org-id'
      window.location = '/courses/' + selection

  $('#btn-add').on 'click', ->
    name = $('#organization').val()
    validate_name name

  $('#btn-unique').on 'click', ->
    term = $('#org-slug').val()
    validate_slug term

  $('#btn-submit-org').on 'click', ->
    validate()

validate_slug = (term) ->
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

validate_name = (name) ->
  org_pattern = /// ^   # start of line
    [a-zA-Z\s*]+        # one or more words
    \s*                 # followed by optional white space
    \([A-Z]{2,6}\)      # followed by 2 to 6 capitalised letters in paranthesis
    $ ///               # end of line

  valid = name.match org_pattern
  if !valid or name == ''
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
  valid = validate_slug($('#org-slug').val()) &&
    validate_name($('#organization').val())
