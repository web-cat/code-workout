const url = "https://skynet.cs.vt.edu/peml-live/api/parse";

// 获取 PEML 数据
fetch('/data/s7.peml')
  .then(response => {
    return response.text();
  })
  .then(pemlText => {
    const payload = {
      "peml": pemlText,
      "output_format": "json",
      "render_to_html": "true"
    };

    // 发送 POST 请求进行解析
    $.post(url, payload, function(data, status) {
      console.log('Post status:', status);
      console.log('Post data:', data);

      // 检查服务器响应数据是否包含所需字段
      if (data && data.title && data.instructions && data.assets && data.assets.code && data.assets.code.starter && data.assets.code.starter.files && data.assets.code.starter.files[0] && data.assets.code.starter.files[0].content) {
        // 获取你需要的字段
        var title = data.title.split(" -- ")[0];
        var instructions = data.instructions;
        var initialArray = data.assets.code.starter.files[0].content.map(item => item.code.split('\\n'));

        // 在这里使用你获取的字段
        document.getElementById("title").innerHTML = title;
        document.getElementById("instructions").innerHTML = instructions;

        var parson = new ParsonsWidget();
        parson.init(initialArray);
        parson.shuffleLines();

        $("#newInstanceLink").click(function(event) {
          event.preventDefault();
          parson.shuffleLines();
        });

        $("#feedbackLink").click(function(event) {
          event.preventDefault();
          var fb = parson.getFeedback();
          $("#feedback").html(fb.feedback);
          if (fb.success) {
            score = 50;
          } else {
            score = 0;
          }
          updateScore(score);
        });

        function updateScore(score) {
          // 更新分数的代码
        }
      } else {
        console.error('服务器响应数据不完整或格式不正确');
        // 在这里处理服务器响应数据不完整或格式不正确的情况
      }
    });
  });