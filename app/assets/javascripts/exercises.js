(function() {
    var handle_submit;

    $(document).ready(function() {

        $('#visualize').click(function() {
            return handle_submit_action();
        });
    });

    handle_submit_action = function() {
        var studentCode;
        var exercise_id = $('h1').text().split(" ")[1];

        studentCode = $('#exercise_version_answer_code').val();
        fd = new FormData;

        fd.append('exerciseId', exercise_id);
        fd.append('studentCode', studentCode);

        // url = '/course_offerings'
        url = '/gym/exercises/call_open_pop';

        $.ajax({
            url: url,
            type: 'GET',
            data: {
                exercise_Id: exercise_id,
                code: studentCode
            },
            success: function (data) {
                console.log("pleeeeeeeeeeeeeeeeeeeeas")
            }

        });
    };

    handle_submit = function() {
        var studentCode;
        var exercise_id = $('h1').text().split(" ")[1];

        studentCode = $('#exercise_version_answer_code').val();
        fd = new FormData;

        fd.append('exerciseId', exercise_id);
        fd.append('studentCode', studentCode);

        // url = '/course_offerings'
        url = 'https://192.168.33.10:9210/exercises';

        $.ajax({
                url: url,
                type: 'GET',
                data: {
                    exercise_Id: exercise_id,
                    code: studentCode
                },
                dataType : 'json',
                crossDomain:true,
                success: function (data) {
                    console.log("pleeeeeeeeeeeeeeeeeeeeas")
                }

        });
    };

    handle_submit2 = function() {
        var studentCode;
        var exercise_id = $('h1').text().split(" ")[1];

        studentCode = $('#exercise_version_answer_code').val();
        fd = new FormData;

        fd.append('exerciseId', exercise_id);
        fd.append('studentCode', studentCode);

        // url = '/course_offerings'
        url = 'https://192.168.33.10:9210/exercises';
        function foo(callback) {
            var httpRequest = new XMLHttpRequest();
            httpRequest.onload = function(){ // when the request is loaded
                callback("asdasdasd");// we're calling our method
            };
            httpRequest.open('GET',url);
            httpRequest.send(fd);
        }

        function myHandler(result) {
            window.alert(result);
        }
        foo(myHandler);
    };

    handle_submit3 = function() {
        var studentCode;
        var exercise_id = $('h1').text().split(" ")[1];

        studentCode = $('#exercise_version_answer_code').val();
        fd = new FormData;

        fd.append('exerciseId', exercise_id);
        fd.append('studentCode', studentCode);

        // url = '/course_offerings'
        url = 'https://192.168.33.10:9210/exercises';
        function createCORSRequest(method, url) {
            var xhr = new XMLHttpRequest();
            if ("withCredentials" in xhr) {
                // XHR for Chrome/Firefox/Opera/Safari.
                xhr.open(method, url, true);
            } else if (typeof XDomainRequest != "undefined") {
                // XDomainRequest for IE.
                xhr = new XDomainRequest();
                xhr.open(method, url);
            } else {
                // CORS not supported.
                xhr = null;
            }
            return xhr;
        }
        function getTitle(text) {
            return text.match('<title>(.*)?</title>')[1];
        }
        var xhr = createCORSRequest('GET', url);
        if (!xhr) {
            alert('CORS not supported');
            return;
        }

        // Response handlers.
        xhr.onload = function() {
            var text = xhr.responseText;
            var title = getTitle(text);
            alert('Response from CORS request to ' + url + ': ' + title);
        };

        xhr.onerror = function() {
            alert('Woops, there was an error making the request.');
        };

        xhr.send();
    };


}).call(this);