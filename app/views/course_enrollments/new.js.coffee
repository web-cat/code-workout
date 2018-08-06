# Append the course enrollments dialog to the page body.
$('body').append(
  '<%= escape_javascript(render partial: "course_enrollments/new_enrollment_modal", locals: { course_offerings: @course_offerings }) %>')

#######################################
###        Helper functions         ###
#######################################

alert_incomplete = (element) ->
  element.addClass 'shake'
  setTimeout ->
    element.removeClass 'shake'
  , 1000

check_completeness = ->
  course_offering = $('#course-offering')
  student = $('#student')
  course_role = $('#course-role')

  complete = true
  result = {}
  if course_offering.val() == ''
    complete= false
    alert_incomplete(course_offering)
  else
    result['course_offering'] = course_offering.val()
    result['course_offering_display'] = course_offering.find(':selected').text()

  if !student.data('selection')? || student.data('selection') == ''
    complete = false
    alert_incomplete(student)
  else
    result['user'] = student.data('selection')
    result['user_display'] = student.val()

  if course_role.val() == ''
    complete = false
    alert_incomplete(course_role)
  else
    result['course_role'] = course_role.val()

  result['complete'] = complete
  return result

setup_autocomplete = (parent) ->
  course_offering_select = $('#course-offering')
  course_offering = course_offering_select.val()
  if course_offering != ''
    course_offering_display = course_offering_select.children(':selected').text()
    $('#student').attr 'disabled', false
    $('.searchable').StudentSearch
      course_offering_id: course_offering
      course_offering_display: course_offering_display
      notin: true

#######################################
###        Event handlers           ###
#######################################
$('.searchable').on 'studentSelect', (e) ->
  course_offering_id = e.course_offering_id
  student_id = e.student_id
  student_display = e.student_display
  $('#student').val student_display
  $('#student').data 'selection', e.student_id

$('.searchable').on 'emptyResponse', (e) ->
  $('#student').removeData 'selection'

# attach event handlers for modal display
$('#new-enrollment-modal').on 'hidden.bs.modal', ->
  # remove modal from DOM when it is not required
  $('#new-enrollment-modal').remove()

$('#new-enrollment-modal').on 'shown.bs.modal', ->
  setup_autocomplete()

# attach event handlers for course_enrollments
$('#course-offering').change ->
  setup_autocomplete()
  $('#student').focus()

# handle submit
$('#btn-enroll').on 'click', ->
  form_result = check_completeness()
  if form_result.complete
    $.ajax
      url: "/course_offerings/#{form_result.course_offering}/enroll"
      data: { course_role_id: form_result.course_role, user_id: form_result.user }
      type: 'post'
      dataType: 'json'
      success: (data) =>
        if data['success'] == true
          $('#tab_roster').trigger
            type: 'requestUpdate'
            user_display: form_result.user_display
            course_offering_display: form_result.course_offering.display
            success: data['success']
          $('#new-enrollment-modal').modal('hide')
        else
          message = data['message']
          alert "#{message}" 

# Display the dialog.
$('#new-enrollment-modal').modal('show')
