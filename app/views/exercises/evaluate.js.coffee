att_id = <%= @attempt.andand.id.to_json %>
user_id = <%= current_user.id.to_json %>
is_coding = <%= @exercise.is_coding?.to_json %>
if att_id
  $("#exercisefeedback").show()
  if is_coding
    $("#saved_assurance").html("Your answer has been saved.  You can move on to another exercise if you don't want to wait for more feedback.")
    $(".btn-submit").attr('disabled', 'disabled')
    $("#exercisefeedback").html('<h2>Feedback</h2><i class="fa fa-spinner fa-spin fa-2x"></i>')
    setTimeout ( ->
      $.ajax(url: "/sse/feedback_poll?att_id=#{att_id}")
    ), 1500
  else
    $.ajax(url: "/sse/feedback_poll?att_id=#{att_id}")
else
  $("#saved_assurance").html("Invalid attempt")
  $("#exercisefeedback").hide()
