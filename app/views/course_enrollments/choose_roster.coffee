# Append the roster upload dialog to the page body.
$('body').append(
  '<%= escape_javascript(render partial: "course_enrollments/roster_upload_modal", locals: { course_offerings: @course_offerings }) %>')

#######################################
###        Event handlers           ###
#######################################

$('#rosterfile').on 'change', ->
  filename = $(this).val()
  $('#btn-upload-roster').prop('disabled', !Boolean(filename))

# attach event handlers for modal display
$('#roster-upload-modal').on 'hidden.bs.modal', ->
  # remove modal from DOM when it is not required
  $('#roster-upload-modal').remove()

$('#roster-upload-modal').modal('show')
