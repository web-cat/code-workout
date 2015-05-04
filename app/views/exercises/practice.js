$(document).ready(function(){
  var att_id;
  var uid = $('#iduser').data('iduser');

  jQuery.ajax({
    url: '/last_attempt',
    success: function(e) {
      att_id = e;
    },
    async:false
  });
  
  console.log("Try attempt is "+att_id+"\n");
  $('#exercisefeedback').hide();
  setTimeout(function() {  	
  	console.log("URL is "+window.location.href);  	
  	console.log("ATTR is "+att_id);
	var source = new EventSource('/feedback_send?uid='+uid+'&att_id='+att_id);
	console.log("Established inside");	
	console.log("User is "+uid+"\n and attempt is "+att_id);
	source.addEventListener('feedback_'+uid,function(e){
		console.log("WINTER IS " + e.data);
		$('#exercisefeedback').html("<%= j(render 'ajax_feedback') %>");
        $('#exercisefeedback').show();
	});
  }, 2);		
});

