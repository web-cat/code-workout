console.log "Established inside I"
att_id = <%= JSON.generate @attempt.id %>
user_id = <%= JSON.generate current_user.id %>
source = new EventSource("/feedback_send?uid=#{user_id}&att_id=#{att_id}")
console.log "Established inside II"
source.addEventListener "feedback_#{att_id}",(e)->
  console.log("WINTER IS " + e.data)
  $("#exercisefeedback").show()
  $("#exercisefeedback").html("<%= j(render 'ajax_feedback') %>")


