$('#users').html(
  '<%= escape_javascript render(@users) %>')
$('#users_paginator').html(
  '<%= escape_javascript(paginate(@users, remote: true).to_s) %>')
