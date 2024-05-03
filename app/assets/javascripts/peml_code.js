const url = "https://skynet.cs.vt.edu/peml-live/api/parse";

// Fetch the PEML data from a local file.
fetch('/data/s7.peml')
  .then(response => {
    // Convert the response to text format.
    return response.text();
  })
  .then(pemlText => {
    // Construct the payload to send in the POST request.
    const payload = {
      "peml": pemlText, // The PEML data as text.
      "output_format": "json", // Specify the output format as JSON.
      "render_to_html": "true" // Request HTML rendering.
    };

    // Send a POST request to the server to parse the PEML text.
    $.post(url, payload, function(data, status) {
      console.log('Post status:', status); // Log the status of the POST request.
      console.log('Post data:', data); // Log the data received from the POST request.

      // Check if the server's response contains the necessary fields.
      if (data && data.title && data.instructions && data.assets && data.assets.code && data.assets.code.starter && data.assets.code.starter.files && data.assets.code.starter.files[0] && data.assets.code.starter.files[0].content) {
        // Extract the required fields from the response.
        var title = data.title.split(" -- ")[0]; // Get the title and clean it.
        var instructions = data.instructions; // Get the instructions directly.
        var initialArray = data.assets.code.starter.files[0].content.map(item => item.code.split('\\n')); // Process the initial array of code.

        // Use the extracted fields in your application.
        document.getElementById("title").innerHTML = title; // Display the title.
        document.getElementById("instructions").innerHTML = instructions; // Display the instructions.

        var parson = new ParsonsWidget(); // Create a new ParsonsWidget instance.
        parson.init(initialArray); // Initialize the widget with the initial array.
        parson.shuffleLines(); // Shuffle the lines initially.

        // Add an event listener for creating a new instance of the shuffled lines.
        $("#newInstanceLink").click(function(event) {
          event.preventDefault();
          parson.shuffleLines();
        });

        // Add an event listener for providing feedback.
        $("#feedbackLink").click(function(event) {
          event.preventDefault();
          var fb = parson.getFeedback();
          $("#feedback").html(fb.feedback); // Display the feedback.
          if (fb.success) {
            score = 50; // Set score on success.
          } else {
            score = 0; // Reset score on failure.
          }
          updateScore(score); // Update the score display.
        });

        function updateScore(score) {
          // Implement the logic to update the score in the UI or backend.
        }
      } else {
        console.error('Incomplete or incorrect server response data.');
        // Handle cases where server response data is incomplete or incorrect.
      }
    });
  });
