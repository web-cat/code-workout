$('body').append(
  '<%= escape_javascript(render partial: "exercises/python_ruby_modal") %>')

# Ensure that the dialog gets removed from the DOM when it is closed.
$('#python_ruby_modal').on 'hidden', ->
  $('#python_ruby_modal').remove()

#$('#python_ruby_modal').on 'shown.bs.modal', ->
#  $('#python_ruby_modal_user_id').focus()

#$('#python_ruby_modal #enroll-users-button').button('loading')

# Display the dialog.
$('#python_ruby_modal').modal('show')
