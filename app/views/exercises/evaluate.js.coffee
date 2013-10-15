$('#evaluate').html(
  '<%= escape_javascript render partial: "evaluation_modal"  %>')
$('#evaluation_modal').modal('show')
/*
 $('#evaluation_modal').modal('hide')
*/