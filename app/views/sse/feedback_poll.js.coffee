att_id = <%= JSON.generate @attempt.id %>
setTimeout ( ->
  $.ajax(url: "/sse/feedback_poll?att_id=#{att_id}")
), 2000
