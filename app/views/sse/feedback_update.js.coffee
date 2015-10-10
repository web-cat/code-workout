$("#exercisefeedback").html("<%= j(render 'ajax_feedback' ) %>")

attempt_score = <%= JSON.generate @attempt.score %>
max_points = <%= JSON.generate ExerciseWorkout.find_by(exercise: @exercise, workout: @workout).points %>

if attempt_score == max_points 
  console.log $("#nextbtn") 
  $("#nextbtn").removeClass("btn-next")
  $("#nextbtn").addClass("btn-primary")
  console.log $("#primarybtn")
  $("#primarybtn").removeClass("btn-primary")
  
$('#sidebar').html("<%= j(render 'layouts/sidebar' ) %>")
