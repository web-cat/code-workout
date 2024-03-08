var parson;
$(document).ready(function(){ 
    var index = window.location.pathname.split('/').pop().split('.')[0];
    var score = 0;
    var data;
    Sk.canvas = "studentCanvas";
    $.getJSON('/data/simple_code.json', function(response) {
        data = response;
        var initial = data[index]['initial'];
        var initialArray = initial.split('\n');
        var config = data[index]['parsonsConfig'];
        document.getElementById("title").innerHTML = data[index].title;
        document.getElementById("instructions").innerHTML = data[index].instructions;
        config.sortableId = 'sortable';
        config.trashId = 'sortableTrash';
        console.log(data[index]['parsonsConfig']['turtleModelCode']);
        // 如果config中有turtleModelCode，就把grader改成TurtleGrader
        if (data[index]['parsonsConfig']['turtleModelCode']) {
            config.grader = ParsonsWidget._graders.TurtleGrader;
            console.log("有乌龟")
            
        } else {
            config.grader = ParsonsWidget._graders.LanguageTranslationGrader;
        }
        parson = new ParsonsWidget(config);
        parson.init(initialArray);
        parson.shuffleLines();
    });
    $("#newInstanceLink").click(function(event){
        event.preventDefault();
        parson.shuffleLines();
    });
    $("#feedbackLink").click(function(event){
        event.preventDefault();
        var fb = parson.getFeedback();
        if (data[index]['parsonsConfig']['turtleModelCode']){
            if (fb.success) {
                //把$("#feedback").html(fb.feedback)改成“Great job, you solved the exercise!”
                $("#feedback").html("Great job, you solved the exercise!");
            } else {
                $("#feedback").html("Sorry, your solution does not match the model image");
            }
        }else{
            $("#feedback").html(fb.feedback);
        }
        // $("#unittest").html("<h2>Feedback from testing your program:</h2>" + fb.feedback);
        if (fb.success) {
            score = 50;
        } else {
            score = 0;
        }
        updateScore(score);
    });
    // function for updating the score
    function updateScore(score) {
        //get external_id from the data attribute
        var externalId = $('#exercise-data').data('external-id');
        
        $.ajax({
            url: '/update_score',
            type: 'POST',
            data: JSON.stringify({ 
                experience: score,
                external_id: externalId  
            }),
            contentType: 'application/json',
            headers: {
                'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')  // CSRF token
            },
            success: function(response) {
                console.log('Score updated successfully');
            },
            error: function(xhr) {
                console.log('Failed to update score: ' + xhr.responseText  
                // external_id
                + 'externalId is' + externalId);
            }
        });
    }
});