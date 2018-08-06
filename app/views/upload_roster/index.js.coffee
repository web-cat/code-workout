# Append the course enrollments dialog to the page body.
$('body').append(
  '<%= j render partial: "upload_roster/modal" %>')

# Ensure that the dialog gets removed from the DOM when it is closed.
$('#upload_roster_modal').on 'hidden', ->
  $('#upload_roster_modal').remove()

$('#upload_roster_modal').on 'shown', ->
  $('#upload_roster_modal select').selectpicker()

$('#upload_roster_modal #roster').change ->
  $('#upload_roster_modal #has_csv').val(0)
  $(this).closest('form').submit()

# Display the dialog.
$('#upload_roster_modal').modal 'show'