$("#saved_assurance").html("")
$("#exercisefeedback").html("<%= j(render 'ajax_feedback' ) %>")

attempt_score = <%= JSON.generate @attempt.score %>
is_coding = <%= JSON.generate @exercise.is_coding? %>
max_points = <%= JSON.generate  @max_points %>

if attempt_score >= max_points
  $("#nextbtn").removeClass("btn-next")
  $("#nextbtn").removeClass("btn-default")
  $("#nextbtn").addClass("btn-primary")
  $("#primarybtn").removeClass("btn-primary")
  $("#primarybtn").addClass("btn-default")
  
$('#sidebar').html("<%= j(render 'layouts/sidebar' ) %>")
$('.btn-submit').removeAttr('disabled')