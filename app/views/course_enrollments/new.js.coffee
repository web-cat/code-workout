
# Append the course enrollments dialog to the page body.
$('body').append(
  '<%= escape_javascript(render partial: "course_enrollments/new_enrollment_modal") %>')

# Ensure that the dialog gets removed from the DOM when it is closed.
$('#new-enrollment-modal').on 'hidden', ->
  $('#new-enrollment-modal').remove()

$('#new-enrollment-modal').on 'shown', ->
  $('#course_enrollment_user_id').focus()

# Display the dialog.
$('#new-enrollment-modal').modal('show')
