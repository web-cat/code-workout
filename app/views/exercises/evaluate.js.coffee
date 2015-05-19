att_id = <%= JSON.generate @attempt.id %>
user_id = <%= JSON.generate current_user.id %>
source = new EventSource("/sse/feedback_wait?uid=#{user_id}&att_id=#{att_id}")
$("#exercisefeedback").show()
$("#exercisefeedback").html('<h2>Feedback</h2><i class="fa fa-spinner fa-spin fa-4x"></i>')
source.addEventListener "feedback_#{att_id}",(e)->
  $.ajax(url: "/sse/feedback_update?att_id=#{att_id}")
