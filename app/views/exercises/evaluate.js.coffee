att_id = <%= JSON.generate @attempt.id %>
user_id = <%= JSON.generate current_user.id %>
is_coding = <%= JSON.generate @exercise.is_coding? %>

$("#exercisefeedback").show()

if is_coding
  $("#exercisefeedback").html('<h2>Feedback</h2><i class="fa fa-spinner fa-spin fa-2x"></i>')
  setTimeout ( ->
    $.ajax(url: "/sse/feedback_poll?att_id=#{att_id}")
  ), 1500
else
  $.ajax(url: "/sse/feedback_update?att_id=#{att_id}")

