
(function() {
    var handle_submit;
    var VisualizeButton = null;
    $(document).ready(function() {
        VisualizeButton = $('#visualize');
        VisualizeButton.click(function() {
            
            return handle_submit_action();
        });
    });

    var studentCode;
    handle_submit_action = function() {

        var exercise_id = $('h1').text().split(" ")[1];
        studentCode = $('#exercise_version_answer_code').val();
        var workoutID = VisualizeButton.data('workout');
        var workoutOfferingID = VisualizeButton.data('workout-offering');
        fd = new FormData;

        fd.append('exerciseId', exercise_id);
        fd.append('studentCode', studentCode);

        // url = '/course_offerings'
        url = '/gym/exercises/call_open_pop';

        $.ajax({
            url: url,
            type: 'GET',
            async:    true,
            data: {
                exercise_id: exercise_id,
                code: studentCode,
                workoutID: workoutID,
                workoutOfferingID: workoutOfferingID
            },
            success: function (data) {
                
                studentCode = studentCode.split('\n').join('\\n');
                studentCode = studentCode.substring(studentCode.indexOf('{') + 1, studentCode.indexOf('return'));
                doModal2("", studentCode, data.exercise_trace);
            }
        });
    };
    function doModal2(heading, studentCode, exercise_trace) {
    var html = "<html>\n" +"\<script>\
        var testvisualizerTrace ={\"code\":\"" + studentCode + "\",\"trace\":[" + exercise_trace +"\
        ],\"userlog\":\"Debugger VM maxMemory: 807M \\n \"}\n\
        \n\
        \<\/script>\
        \n\
        \<body onload=\"visualize(testvisualizerTrace);\"/>\n";
    html += "\<head>\n\
        \<title>JSAV example\<\/title>\n \
        <meta charset=\"utf-8\"/>\n \
        <link rel=\"stylesheet\" href=\"https://opendsa-server.cs.vt.edu/OpenDSA/JSAV/css/JSAV.css\" type=\"text/css\"/>\n \
        <link rel=\"stylesheet\" href=\"https://opendsa-server.cs.vt.edu/OpenDSA/lib/odsaAV-min.css\" type=\"text/css\"/>\n \
        <link rel=\"stylesheet\" href=\"https://opendsa-server.cs.vt.edu/OpenDSA/lib/odsaStyle-min.css\" type=\"text/css\"/>\n \
        \<style>\n \
        #container {\n \
        width: 780px;\n \
        height: 380px;\n \
        }\n \
        \<\/style>\n \
        \<\/head>\n";
    html += '\<body>\n\
        \<div id=\"container\">\n\
        \<div class=\"avcontainer\">\n\
        \<span class=\"jsavcounter\">\<\/span>\n\
        <div class=\"jsavcontrols\">\<\/div>\n\
        <p class=\"jsavoutput jsavline\">\<\/p>\n\
        \<\/div> <!--avcontainer-->\n\
        \<\/div> <!--container-->\
        \<script src=\"https://code.jquery.com/jquery-2.1.4.min.js\">\<\/script>\n\
        \<script src=\"https://code.jquery.com/ui/1.11.4/jquery-ui.min.js\">\<\/script>\n\
        \<script src=\"https://opendsa-server.cs.vt.edu/OpenDSA/JSAV/lib/jquery.transit.js\">\<\/script>\n\
        \<script src=\"https://opendsa-server.cs.vt.edu/OpenDSA/JSAV/lib/raphael.js\">\<\/script>\n\
        \<script src=\"https://opendsa-server.cs.vt.edu/OpenDSA/JSAV/build/JSAV-min.js\">\<\/script>\n\
        \<script src=\"https://opendsa-server.cs.vt.edu/OpenDSA/lib/odsaUtils-min.js\">\<\/script>\n\
        \<script src=\"https://opendsa-server.cs.vt.edu/OpenDSA/lib/odsaAV-min.js\">\<\/script>\n\
        \<script src=\"http://192.168.33.10:3000/assets/JsavWrapper.js\">\<\/script>\n\
        \n\
        \<\/body>' + "</html>";
        if(document.getElementsByTagName('iframe').length !== 0)
        {
            document.getElementById('ModalBody').removeChild(document.getElementsByTagName('iframe')[0]);
        }
        window.setTimeout(function(){ showIframe(html);}, 500);
        $('#Visualize').modal('toggle');

    };
    function showIframe(html){
        var iframe = document.createElement('iframe');
        document.getElementById('ModalBody').appendChild(iframe);
        var iframeDoc = iframe.contentDocument;
        $(iframeDoc).ready(function (event) {
            iframeDoc.open();
           
            //html = html.replace("'",'"');
            //html = html.replace(/[^/\"_+-?![]{}()=*.|a-zA-Z 0-9]+/g,'');               
            iframeDoc.write(html)               
            iframeDoc.close();
            iframe.height = "400px";
            iframe.width = "800px";
        });             
        
    };
}).call(this);
