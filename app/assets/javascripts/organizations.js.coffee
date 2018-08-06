ORGANIZATION = '#organization'
COURSE = '#course'

$(document).ready ->
  $('#term_id').change ->
    enrolled_only = $('#enrolled_only').val()
    window.location.href = "?enrolled_only=#{enrolled_only}&term_id=" + $('#term_id').val()

$('.organizations.new_or_existing').ready ->
  setup_autocomplete '/organizations/search', ORGANIZATION

  $('#organization').on 'blur', ->
    val = $('#organization').val()
    selection = $('#organization').data 'org-id'
    if !selection?
      get_abbr_suggestion val

  $('#btn-org').on 'click', ->
    $('.new-org').css 'display', 'none'
    $('#organization').val ''
    $('#organization').autocomplete 'enable'

  $('#btn-course').on 'click', ->
    if $(this).text() == 'Cancel'
      $('.new-course').css 'display', 'none'
      $('#course').val ''
      $('#course').autocomplete 'enable'
    else if $(this).text() == 'Continue'
      org = $('#organization').data 'org-id'
      course = $('#course').data 'course-id'
      window.location.href = "/courses/#{org}/#{course}/new_offering"

  $('#btn-add').on 'click', ->
    name = $('#organization').val()
    validate_name name, ORGANIZATION

  org_keyup = null
  $('#abbr').keyup ->
    clearTimeout org_keyup
    org_keyup = setTimeout ->
      term = $('#abbr').val()
      if term == ''
        $('#org-hint').text ''
      validate_org_slug term
    , 750

  course_keyup = null
  $('#number').keyup ->
    clearTimeout course_keyup
    course_keyup = setTimeout ->
      term = $('#number').val()
      if term == ''
        $('#course-hint').text ''
      validate_course_number term
    , 750


  $('#btn-submit-org').on 'click', ->
    handle_submit_organization()

  $('#btn-submit-course').on 'click', ->
    handle_submit_course()

get_abbr_suggestion = (org_name)->
  lowers = ['the', 'and', 'for', 'at', 'in', 'of']
  $.ajax
    url: '/organizations/abbr_suggestion'
    type: 'get'
    dataType: 'json'
    data: { name: org_name }
    success: (data)->
      if data['abbr']
        # $('#abbr').attr 'placeholder', data['abbr']
        $('#abbr').val(data['abbr'])
        validate_org_slug(data['abbr'])
      else
        $('#org-hint').text data['msg']

validate_org_slug = (term)->
  term = term.toLowerCase()
  uniqueness = $('#uniqueness')
  uniqueness.removeClass()
  if term == ''
    $('#org-hint').text("This is a required field")
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
          $('#org-hint').text(msg)
          return false

validate_name = (name, field)->
  if name == ''
    # add the class to trigger the animation
    # then remove it, so that the animation can re-run next time
    hint_to_shake = if field == ORGANIZATION then '#hint' else '#new-course-hint'
    $(hint_to_shake).addClass 'shake'
    setTimeout ->
      $(hint_to_shake).removeClass 'shake'
    , 1000
    return false
  else
    return true

validate_course_number = (number)->
  r = /// ^         # beginning of line
    ([A-Z]{2,})     # 2 or more letters
    \s*             # followed by optional whitespace
    ([0-9]{3,})     # followed by 3 or more digits
  $ ///             # end of line

  if number == ''
    $('#course-valid').removeClass()
    $('#course-valid').addClass 'fa fa-times-circle text-danger'
    $('#course-hint').html('This is a required field.') 
  else if number.match(r)
    $('#course-valid').removeClass().addClass('fa fa-spinner')
    $('#course-hint').empty()
    slug = number.toLowerCase()
    slug = slug.replace(/\s+/g, '')
    org_id = $('#organization').data 'org-id'
    $.ajax
      url: '/courses/' + org_id + '/search'
      type: 'get'
      dataType: 'json'
      data: { term: slug, slug: true }
      success: (data)->
        if data?
          $('#course-valid').removeClass().addClass 'fa fa-times-circle text-danger'
          org_name = $('#organization').val()
          msg = "Sorry, that course number is in use by <em>#{data.name}</em> at #{org_name}"
          $('#course-hint').html msg
        else
          $('#course-valid').removeClass().addClass 'fa fa-check-circle text-success'
          $('#course-hint').empty()
  else
    $('#course-valid').removeClass()
    $('#course-valid').addClass 'fa fa-times-circle text-danger'
    $('#course-hint').html 'Please follow this format: <em>CS 1114</em>'

validate = (field)->
  if field == ORGANIZATION
    valid = validate_org_slug($('#abbr').val()) &&
      validate_name($('#organization').val(), field)
  else
    valid = validate_course_number($('#number').val()) &&
      validate_name($('#course').val(), field)

  return valid

setup_autocomplete = (url, field_id)->
  if field_id == COURSE
    $('.org-setup :input').attr 'disabled', true
    $('.course-setup').css 'display', 'block'

  autocomplete = $(field_id).autocomplete
    minLength: 2
    autoFocus: true
    source: url
    response: (event, ui) ->
      ui.content.push({ name: '+ Add new' }) #empty number
    select: (event, ui)->
      return handle_select_from_autocomplete event, ui, field_id

  autocomplete.data('ui-autocomplete')._renderItem = (ul, item) ->
    val = item.name
    if item.number?
      val = "#{item.number} - #{item.name}"
    return $('<li class="list-group-item"></li>')
      .append(val)
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
    val = ui.item.name
    if ui.item.number?
      val = "#{ui.item.number} - #{ui.item.name}"
    field.val val
    field.data data, ui.item.slug
    if field_id == ORGANIZATION
      setup_autocomplete '/courses/' + ui.item.slug + '/search', COURSE
    else if field_id == COURSE
      $('#btn-course').text 'Continue'
      $('#btn-course').css 'display', 'block'
  else
    if field_id == ORGANIZATION
      val = field.val()
      get_abbr_suggestion val
    else if field_id == COURSE
      $('#btn-course').text('Cancel')

    field.removeData data
    field.autocomplete 'disable'
    $(additional_fields).css 'display', 'block'
  return false

handle_submit_course = ->
  valid = validate(COURSE)
  if valid
    org_id = $('#organization').data 'org-id'
    course_name = $('#course').val()
    course_number = $('#number').val()
    is_hidden = $('#course-is-hidden').is ':checked'
    # enforce the format 'CS 1114' (including the space)
    dept = course_number.match(/^([A-Z]+)/g)
    number = course_number.match(/([0-9]+)$/g)
    course_number = "#{dept} #{number}"
    slug = course_number.replace('/\s+/', '')
    form_data = {
      course: {
        number: course_number
        slug: slug
        name: course_name,
        is_hidden: is_hidden
      }
    }
    $.ajax
      url: "/courses/#{org_id}/create"
      type: 'post'
      dataType: 'json'
      data: form_data
      success: (data)->
        if data['success']?
          window.location.href = data['url']
        else
          console.log data['message']

handle_submit_organization = ->
  valid = validate(ORGANIZATION)
  if valid
    name = $('#organization').val()
    abbr = $('#abbr').val()
    is_hidden = $('#org-is-hidden').is ':checked'
    $.ajax
      url: '/organizations/'
      type: 'post'
      data: { name: name, abbreviation: abbr, is_hidden: is_hidden }
      dataType: 'json'
      success: (data)->
        if data['success']
          $('#organization').data 'org-id', data['id']
          setup_autocomplete '/courses/' + data['id'] + '/search', COURSE
