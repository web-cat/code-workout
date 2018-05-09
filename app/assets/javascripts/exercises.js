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
            async:    true,
            data: {
                exercise_id: exercise_id,
                code: studentCode
            },
            success: function (data) {
                
                studentCode = studentCode.split('\n').join('\\n');
                studentCode = studentCode.split('{')[1].split('return')[0];
                var visWindow = window.open("", "Visualize", "_blank",'height=400, width=800');
                var html = "<!DOCTYPE html>\n" +
                "<html>\n" +"\<script>\
                var testvisualizerTrace ={\"code\":\"" + studentCode + "\",\"trace\":[" + data.exercise_trace +"\
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
                \<script src=\"https://opendsax.cs.vt.edu:9292/assets/JsavWrapper.js\">\<\/script>\n\
                \n\
                \<\/body>' + "</html>";                 
                    //"</html>";
                visWindow.document.write(html);
                visWindow.document.close();
                doModal2("", studentCode, data.exercise_trace);
            }
        });
    };
    function doModal(heading, studentCode, exercise_trace) {
        var iframe = document.getElementById('VisualizeIFrame');
        //if(document.getElementsByTagName('iframe').length === 0)
        //{
           // document.getElementById('VisualizeModal').appendChild(iframe);
        var iframeDoc = iframe.contentDocument;
        $(iframeDoc).ready(function (event) {
            iframeDoc.open();
            iframeDoc.write("<html>\n" +"\<script>\
                var testvisualizerTrace ={\"code\":\"" + studentCode + "\",\"trace\":[" + exercise_trace +"\
                ],\"userlog\":\"Debugger VM maxMemory: 807M \\n \"}\n\
                \n\
                \<\/script>\
                \n\
                \<body onload=\"visualize(testvisualizerTrace);\"/>\n");
            
            iframeDoc.write("\<head>\n\
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
                \<\/head>\n");

            iframeDoc.write('\<body>\n\
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
                \<script src=\"https://opendsax.cs.vt.edu:9292/assets/JsavWrapper.js\">\<\/script>\n\
                \n\
                \<\/body>'+ "</html>");                 
            iframeDoc.close();
            
        });
    //}
        $('#VisualizeModal').modal('toggle');
        //$('#VisualizeModal').find('.modal-body').html(html);
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
        \<script src=\"https://opendsax.cs.vt.edu:9292/assets/JsavWrapper.js\">\<\/script>\n\
        \n\
        \<\/body>' + "</html>";
        if(document.getElementsByTagName('iframe').length !== 0)
        {
            document.getElementById('ModalBody').removeChild(document.getElementsByTagName('iframe')[0]);
        }
        var iframe = document.createElement('iframe');
        document.getElementById('ModalBody').appendChild(iframe);
        var iframeDoc = iframe.contentDocument;
        $(iframeDoc).ready(function (event) {
          iframeDoc.open();
        iframeDoc.write(html);                 
        iframeDoc.close();
        iframe.height = "400px";
        iframe.width = "800px";
        });                     
        //$('#ModalBody').append(iframe);
        $('#VisualizeModal').modal('toggle');

    };
}).call(this);

