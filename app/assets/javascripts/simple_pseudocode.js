// This file is used to create a Parsons problem for the simple pseudocode exercise
var initial = 'IF $$toggle::a::b$$ $$toggle::<::>::<>$$ b THEN\n  min := a\nELSE\n  min := b\nENDIF';
var parson;
$(document).ready(function(){
    var score = 0;
    parson = new ParsonsWidget({
        'sortableId': 'sortable',
        'trashId': 'sortableTrash',
        'max_wrong_lines': 1,
        'vartests': [{initcode: "min = None\na = 0\nb = 2", code: "", message: "Testing with a = 0 ja b = 2", variables: {min: 0}},
            {initcode: "min = None\na = 7\nb = 4\n", code: "", message: "Testing with a = 7 ja b = 4",
              variables: {min: 4}}],
        'grader': ParsonsWidget._graders.LanguageTranslationGrader,
        'executable_code': "if $$toggle$$ $$toggle::<::>::!=$$ b:\n" +
              "min = a\n" +
              "else:\n" +
              "min = b\n  pass",
        'programmingLang': "pseudo"
    });
    var initialArray = initial.split('\n');
    parson.init(initialArray);
    parson.shuffleLines();
    $("#newInstanceLink").click(function(event){
        event.preventDefault();
        parson.shuffleLines();
    });
    $("#feedbackLink").click(function(event){
        event.preventDefault();
        console.log($('#sortablecodeline0').html());
        var fb = parson.getFeedback();
        $("#feedback").html(fb.feedback);
        // $("#unittest").html("<h2>Feedback from testing your program:</h2>" + fb.feedback);
        if (fb.success) {
            score = 50;
            updateScore(score);
        }
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
                console.log('Failed to update score: ' + xhr.responseText);
            }
        });
    }
});