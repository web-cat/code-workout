<%= remotipart_response do %>
<% if params[:commit] %>
# This submit came from clicking the submit button, so dismiss
# the modal.
$('#upload_roster_modal').modal 'hide'
<% else %>
# This submit came from the file upload control, so update and
# display the preview table.
$('#upload_roster_modal #roster-preview-wrapper').html(
  '<%= j render partial: "table" %>')
$('#upload_roster_modal #roster-section2').slideDown()
$('#upload_roster_modal select').selectpicker()
<% end %>
<% end %>