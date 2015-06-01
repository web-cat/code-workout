att_id = <%= JSON.generate @attempt.id %>
user_id = <%= JSON.generate current_user.id %>
is_coding = <%= JSON.generate @exercise.is_coding? %>

$("#exercisefeedback").show()

if is_coding
  source = new EventSource("/sse/feedback_wait?uid=#{user_id}&att_id=#{att_id}")
  $("#exercisefeedback").html('<h2>Feedback</h2><i class="fa fa-spinner fa-spin fa-2x"></i>')
  source.addEventListener "feedback_#{att_id}",(e)->
    $.ajax(url: "/sse/feedback_update?att_id=#{att_id}")
    source.close
else
  $.ajax(url: "/sse/feedback_update?att_id=#{att_id}")

