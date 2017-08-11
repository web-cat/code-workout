$("#saved_assurance").html("")
$("#exercisefeedback").html("<%= j(render 'ajax_feedback' ) %>")

attempt_score = <%= JSON.generate @attempt.score %>
max_points = <%= JSON.generate  @max_points %>

if attempt_score >= max_points
  $("#nextbtn").removeClass("btn-next")
  $("#nextbtn").removeClass("btn-default")
  $("#nextbtn").addClass("btn-primary")
  $("#primarybtn").removeClass("btn-primary")
  $("#primarybtn").addClass("btn-default")

$('#sidebar').html("<%= j(render 'layouts/sidebar' ) %>")
subbtn = $('.btn-submit')
if subbtn?
  subbtn.removeAttr('disabled')

tcrs = <%= raw @attempt.prompt_answers.first.specific.test_case_results(true).where.not(execution_feedback: :null)
          .select("test_case_id, execution_feedback, feedback_line").to_json %>;
clearLineWidgets();
for tcr in tcrs
  if tcr.feedback_line
    lines = tcr.feedback_line.split " "
    for line_num in lines
      text="Error: " + tcr.execution_feedback
      addLineWidget(text, parseInt(line_num,10) - 1, 'error')