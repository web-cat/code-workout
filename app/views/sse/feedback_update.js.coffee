$("#saved_assurance").html("")
$("#exercisefeedback").html("<%= j(render 'ajax_feedback' ) %>")

attempt_score = <%= JSON.generate @attempt.score %>
is_coding = <%= JSON.generate @exercise.is_coding? %>
max_points = <%= JSON.generate  @max_points %>
show_perfect = <%= JSON.generate @can_show_perfect %>

console.log "IS CODING " + is_coding
console.log "SHOW PERFECT? " + show_perfect

if attempt_score == max_points and is_coding and show_perfect
  console.log $("#nextbtn")
  $("#nextbtn").removeClass("btn-next")
  $("#nextbtn").removeClass("btn-default")
  $("#nextbtn").addClass("btn-primary")
  console.log $("#primarybtn")
  $("#primarybtn").removeClass("btn-primary")
  $("#primarybtn").addClass("btn-default")

$('#sidebar').html("<%= j(render 'layouts/sidebar' ) %>")
