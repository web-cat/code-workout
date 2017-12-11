(function() {
    var handle_submit;

    $(document).ready(function() {

        $('#visualize').click(function() {
            return handle_submit();
        });
    });

    handle_submit = function() {
        var studentCode;

        studentCode = $('#exercise_version_answer_code').val();
        fd = new FormData;
        fd.append('studentCode', studentCode);

        // url = '/course_offerings'
        url = 'https://192.168.33.10:9210/exercises'
        return $.ajax({
            url: url,
            type: 'post',
            data: fd,
            processData: false,
            contentType: false,
            success: function(data) {
            }
        });
    };

}).call(this);