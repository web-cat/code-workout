att_id = <%= JSON.generate @attempt.id %>
user_id = <%= JSON.generate @student_drift_user.id %>
is_coding = <%= JSON.generate @exercise.is_coding? %>
feedback_timeout = <%= JSON.generate Rails.application.config.feedback_timeout %>
feedback_padding = <%= JSON.generate Rails.application.config.feedback_timeout_padding %>

setTimeout ( ->
  $.ajax(url: "/sse/feedback_poll?att_id=#{att_id}")
), feedback_timeout + feedback_padding
