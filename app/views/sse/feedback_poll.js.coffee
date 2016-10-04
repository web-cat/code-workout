att_id = <%= @attempt.id.to_json %>
user_id = <%= current_user.id.to_json %>
is_coding = <%= @exercise.is_coding?.to_json %>

setTimeout ( ->
  $.ajax(url: "/sse/feedback_poll?att_id=#{att_id}")
), 2800
