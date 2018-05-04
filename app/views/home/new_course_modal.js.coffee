$('body').append(
  '<%= escape_javascript(render partial: "course_offerings/new_modal") %>')

# Ensure that the dialog gets removed from the DOM when it is closed.
$('#new_course_modal').on 'hidden', ->
  $('#new_course_modal').remove()

#$('#new_course_modal').on 'shown.bs.modal', ->
#  $('#new_course_modal_user_id').focus()

#$('#new_course_modal #enroll-users-button').button('loading')

# Display the dialog.
$('#new_course_modal').modal('show')
