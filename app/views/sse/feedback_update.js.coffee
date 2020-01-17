$("#saved_assurance").html("")
$("#exercisefeedback").html("<%= j(render 'ajax_feedback' ) %>")

attempt_score = <%= @attempt.score %>
max_points = <%= @max_points %>
attempts_exhausted = <%= @attempts_exhausted %>

if attempt_score >= max_points
  $("#nextbtn").removeClass("btn-next")
  $("#nextbtn").removeClass("btn-default")
  $("#nextbtn").addClass("btn-primary")
  $("#primarybtn").removeClass("btn-primary")
  $("#primarybtn").addClass("btn-default")

$('#sidebar').html("<%= j(render 'layouts/sidebar' ) %>")
subbtn = $('.btn-submit')
if subbtn? && !attempts_exhausted
  subbtn.removeAttr('disabled')
  $('#visualize').removeAttr('disabled')


editor = codemirrors[0].editor
clearLineWidgets(editor)
attempt_error_line_no =
  '<%= @attempt.prompt_answers.first.specific.error_line_no %>'
if attempt_error_line_no
  addLineWidget(editor, '<%= @attempt.prompt_answers.first.specific.error %>',
    attempt_error_line_no, 'error')

tcrs = <%= raw @attempt.prompt_answers.first.specific.test_case_results(true).
           where.not(execution_feedback: :null).
          select("test_case_id, execution_feedback, feedback_line_no").to_json %>;
for tcr in tcrs
  if tcr.feedback_line_no
    addLineWidget(editor, 'Error: ' + tcr.execution_feedback,
      tcr.feedback_line_no, 'error')
