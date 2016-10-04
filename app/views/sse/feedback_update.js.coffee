$("#saved_assurance").html("")
$("#exercisefeedback").html("<%= j(render 'ajax_feedback' ) %>")

attempt_score = <%= @attempt.score.to_json %>
is_coding = <%= @exercise.is_coding?.to_json %>
max_points = <%= @max_points.to_json %>

if attempt_score >= max_points
  $("#nextbtn").removeClass("btn-next")
  $("#nextbtn").removeClass("btn-default")
  $("#nextbtn").addClass("btn-primary")
  $("#primarybtn").removeClass("btn-primary")
  $("#primarybtn").addClass("btn-default")

$('#sidebar').html("<%= j(render 'layouts/sidebar' ) %>")
$('.btn-submit').removeAttr('disabled')