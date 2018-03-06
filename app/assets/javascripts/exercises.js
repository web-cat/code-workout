(function() {
    var handle_submit;

    $(document).ready(function() {

        $('#visualize').click(function() {
            return handle_submit_action();
        });
    });
    var studentCode;
    handle_submit_action = function() {

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
            async:    false,
            data: {
                exercise_id: exercise_id,
                code: studentCode
            },
            success: function (data) {
                studentCode = studentCode.split('\n').join('\\n');
                studentCode = studentCode.split('{')[1].split('return')[0];

                var visWindow = window.open("", "Visualize", "_blank",'height=800, width=800');
                html = "<!DOCTYPE html>\n" +
                    "<html>\n" +
                    "<script>" +
                    "var testvisualizerTrace ={\"code\":\"" +
                     studentCode+
                    "\",\"trace\":["
                    + data.exercise_trace+
                    "],\"userlog\":\"Debugger VM maxMemory: 807M \\n \"}\n" +
                    "\n" +
                    "</script>\n" +
                    "\n" +
                    "\n" +
                    "\n" +
                    "\n" +
                    "<body onload=\"visualize(testvisualizerTrace);\"/>\n" +
                    "<head>\n" +
                    "    <title>JSAV example</title>\n" +
                    "    <meta charset=\"utf-8\"/>\n" +
                    "    <link rel=\"stylesheet\" href=\"http://192.168.33.10:3000/assets/JSAV.css\" type=\"text/css\"/>\n" +
                    "    <link rel=\"stylesheet\" href=\"http://192.168.33.10:3000/assets/odsaAV-min.css\" type=\"text/css\"/>\n" +
                    "    <link rel=\"stylesheet\" href=\"http://192.168.33.10:3000/assets/odsaStyle-min.css\" type=\"text/css\"/>\n" +
                    "    <style>\n" +
                    "        #container {\n" +
                    "            width: 780px;\n" +
                    "            height: 540px;\n" +
                    "        }\n" +
                    "    </style>\n" +
                    "</head>\n" +
                    "\n" +
                    "<body>\n" +
                    "<div id=\"container\">\n" +
                    "    <div class=\"avcontainer\">\n" +
                    "        <span class=\"jsavcounter\"></span>\n" +
                    "        <div class=\"jsavcontrols\"></div>\n" +
                    "        <p class=\"jsavoutput jsavline\"></p>\n" +
                    "    </div> <!--avcontainer-->\n" +
                    "</div> <!--container-->"+
                    "<script src=\"http://192.168.33.10:3000/assets/jquery-2.1.4.min.js\"></script>\n" +
                    "<script src=\"http://192.168.33.10:3000/assets/jquery-ui.min.js\"></script>\n" +
                    "<script src=\"http://192.168.33.10:3000/assets/jquery.transit.js\"></script>\n" +
                    "<script src=\"http://192.168.33.10:3000/assets/raphael.js\"></script>\n" +
                    "<script src=\"http://192.168.33.10:3000/assets/JSAV-min.js\"></script>\n" +
                    "<script src=\"http://192.168.33.10:3000/assets/odsaUtils-min.js\"></script>\n" +
                    "<script src=\"http://192.168.33.10:3000/assets/odsaAV-min.js\"></script>\n" +
                    "<script src=\"http://192.168.33.10:3000/assets/JsavWrapper.js\"></script>\n" +
                    "\n" +
                    "</body>"+
                    "</html>";
                visWindow.document.write(html);
                visWindow.document.close();
            }

        });
    };
    function doModal(heading, formContent) {
        html =  '<div id="dynamicModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="confirm-modal" aria-hidden="true">';
        html += '<div class="modal-dialog">';
        html += '<div class="modal-content">';
        html += '<div class="modal-header">';
        html += '<a class="close" data-dismiss="modal">×</a>';
        html += '<h4>'+heading+'</h4>'
        html += '</div>';
        html += '<div class="modal-body">';
        html += formContent;
        html += '</div>';
        html += '<div class="modal-footer">';
        html += '<span class="btn btn-primary" data-dismiss="modal">Close</span>';
        html += '</div>';  // content
        html += '</div>';  // dialog
        html += '</div>';  // footer
        html += '</div>';  // modalWindow

        $('body').append(html);

        $("#dynamicModal").modal();
        $("#dynamicModal").modal('show');

        $('#dynamicModal').on('hidden.bs.modal', function (e) {
            $(this).remove();
        });

    }
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

        fd.append('exercise_id', exercise_id);
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
