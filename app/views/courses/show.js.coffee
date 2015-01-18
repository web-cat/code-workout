$('#rosterer').html(
  '<%= escape_javascript render(:partial => 'courses/roster') %>')
$('#roster_paginator').html(
  '<%= escape_javascript(paginate(@sec, remote: true).to_s) %>')
