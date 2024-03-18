$(document).ready(function () {
    "use strict";
    // const url = "https://skynet.cs.vt.edu/peml-live/api/parse"
    // const payload = {"peml": "peml/text", "output_format": "json", "render_to_html": "true"}
    // $(.btn).click(function(){
    //     $.post(url, data, function(data, status){
    //         console.log(data)
    //     });
    // })
    
    var index = window.location.pathname.split('/').pop().split('.')[0];
    var parson = new ParsonsWidget({
        'sortableId': 'sortable',
        'trashId': 'sortableTrash',
        'max_wrong_lines': 0,
        'feedback_cb' : displayErrors
    });
    var noCredit = true
    var score = 0
    function displayErrors(fb) {
        var feedbackElement = document.getElementById('feedback');
        if (fb.errors.length === 0 && noCredit) {
            noCredit = false
          //ODSA.AV.awardCompletionCredit()
          console.log("awarded CompletionCredit");
          score = 50
          feedbackElement.textContent = 'Your answer is Correct!';
        } 
        if (fb.errors.length > 0) {
            alert(fb.errors[0])
            feedbackElement.textContent = 'Your answer is Incorrect!';
        }
    }

    var trace = [{
        "input": "0_0-2_0",
        "output": "1_0"
    },
    {   
        "input": "0_0",
        "output": "2_1-1_0"
    },
    {
        "input": "0_0",
        "output": "2_2-1_0"
    },
    {
        "input": "0_0",
        "output": "1_1-2_2"
    },
    {
        "input": "-",
        "output": "0_1-2_2-1_0"
    }]
    var parsedTrace;

    $.getJSON("/data/simple.json", function(data) {
        var initial = data[index].initial
        document.getElementById("title").innerHTML = data[index].title
        document.getElementById("instructions").innerHTML = data[index].instructions
        parson.init(initial)
        //parson.loadProgress()
        parson.shuffleLines();
        parsedTrace = parson.parseTrace(trace)
        var externalId = $('#exercise-data').data('external-id');
        console.log(externalId);
    });
    $("#newInstanceLink").click(function (event) {
        event.preventDefault()
        parson.shuffleLines()
    });
    $("#feedbackLink").click(function (event) {
        var initData = {}
        initData.user_code = parson.studentCode()
        //ODSA.AV.logExerciseInit(initData)
        event.preventDefault()
        parson.getFeedback() 
        updateScore(score);
    });
    $('#loadProgressLink').click(function() {
        // parson.loadProgress(sorted, trash, indents)
        // const state = parson.getState({index: index})
        // console.log(state)
        // $.ajax({
        //     url: '/saveProgress',
        //     type: 'POST',
        //     async: false,
        //     data: JSON.stringify(state),
        //     contentType: 'application/json; charset=utf-8',
        //     dataType: 'json',
        //     xhrFields: {
        //         withCredentials: true
        //     },
        //     success: function(data) {
        //         console.log(data)
        //     }
        // })
    });
    $("#prevInput").click(function () {
        parson.prevActionInput(parsedTrace)
    });
    $("#nextInput").click(function () {
        parson.nextActionInput(parsedTrace)
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
                console.log('Score updated successfully' + // external_id
                 'externalId is' + externalId);
            },
            error: function(xhr) {
                console.log('Failed to update score: ' + xhr.responseText
                // external_id
                + 'externalId is' + externalId);
            }
        });
    }

});

