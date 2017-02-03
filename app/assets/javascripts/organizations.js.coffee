$(document).ready ->
  $('#term_id').change ->
    window.location.href = '?term_id=' + $('#term_id').val()

  autcomplete = $('.select-org').autocomplete
    minLength: 2
    source: '/organizations/search'
    response: (event, ui) ->
      ui.content.unshift({ name: '+ Add new organization' })
    select: (event, ui) ->
      if ui.item.slug?
        $('.select-org').val ui.item.name
        $('.select-org').data 'org-id', ui.item.slug
      else
        $('.select-org').val ''
        $('.select-org').removeData 'org-id'
        $('.new-msg').css 'display', 'inline'
        $('.select-org').autocomplete 'disable'
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
