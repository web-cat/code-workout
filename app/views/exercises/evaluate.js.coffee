att_id = <%= JSON.generate @attempt.andand.id %>
user_id = <%= JSON.generate @student_drift_user.id %>
is_coding = <%= JSON.generate @exercise.is_coding? %>
attempts_exhausted = <%= JSON.generate(@attempts_left == 0) %>
feedback_timeout = <%= JSON.generate Rails.application.config.feedback_timeout %>
feedback_padding = <%= JSON.generate Rails.application.config.feedback_timeout_padding %>

feedback_poll_url = "/sse/feedback_poll?att_id=#{att_id}&drift_user_id=#{user_id}" +
  "&attempts_exhausted=#{attempts_exhausted}"

if att_id
  $("#exercisefeedback").show()
  if is_coding
    $("#saved_assurance").html("Your answer has been saved.  You can move on to another exercise if you don't want to wait for more feedback.")
    $(".btn-submit").attr('disabled', 'disabled')
    $("#visualize").attr('disabled', 'disabled')
    $("#exercisefeedback").html('<h2>Feedback</h2><i class="fa fa-spinner fa-spin fa-2x"></i>')
    setTimeout ( ->
      $.ajax(url: feedback_poll_url)
    ), feedback_timeout + feedback_padding
  else
    $.ajax(url: feedback_poll_url)
  
  attempt_html = "<%= j(render 'exercises/attempts_left', attempts_left: @attempts_left) %>"
  $('#attempts-left').html(attempt_html)
  if attempts_exhausted
    $('.btn-submit').prop('disabled', true)
else
  $("#saved_assurance").html("Invalid attempt")
  $("#exercisefeedback").hide()
