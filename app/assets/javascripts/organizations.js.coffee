$(document).ready ->
  $('#term_id').change ->
    window.location.href = '?term_id=' + $('#term_id').val()
