att_id = <%= JSON.generate @attempt.andand.id %>
user_id = <%= JSON.generate @student_drift_user.id %>
is_coding = <%= JSON.generate @exercise.is_coding? %>
if att_id
  $("#exercisefeedback").show()
  if is_coding
    $("#saved_assurance").html("Your answer has been saved.  You can move on to another exercise if you don't want to wait for more feedback.")
    $(".btn-submit").attr('disabled', 'disabled')
    $("#visualize").attr('disabled', 'disabled')
    $("#exercisefeedback").html('<h2>Feedback</h2><i class="fa fa-spinner fa-spin fa-2x"></i>')
    setTimeout ( ->
      $.ajax(url: "/sse/feedback_poll?att_id=#{att_id}&drift_user_id=#{user_id}")
    ), 2000
  else
  $.ajax(url: "/sse/feedback_poll?att_id=#{att_id}&drift_user_id=#{user_id}")
else
  $("#saved_assurance").html("Invalid attempt")
  $("#exercisefeedback").hide()
