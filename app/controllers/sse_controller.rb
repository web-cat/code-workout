class SseController < ApplicationController
  include ActionController::Live

  # -------------------------------------------------------------
  def feedback_wait
    max_attempt = params[:att_id]
    @attempt = Attempt.find_by(id: params[:att_id])
    authorize! :read, @attempt

    response.headers['Content-Type'] = 'text/event-stream'

    # Feedbacker::SSE.new(response.stream)
    sse = SSE.new(response.stream, retry: 300,
      event: "feedback_#{params[:att_id]}")

    flag = true
    ActiveSupport::Notifications.subscribe(
      "record_#{max_attempt}_attempt") do |*args|
      begin
        sse.write({arg: args})
      rescue IOError
        puts 'IOError', 'IOError', 'IOError'
      ensure
        flag = false
        sse.close
      end
    end
    while flag
      sleep(1)
    end
    render nothing: true
  end


  # -------------------------------------------------------------
  def feedback_update
    @attempt = Attempt.find_by(id: params[:att_id])
    authorize! :read, @attempt
    @exercise_version = @attempt.exercise_version
    @exercise = @exercise_version.exercise
    @max_points = ExerciseWorkout.find_by(exercise: @exercise, workout: @workout).andand.points
    respond_to do |format|
      format.js
    end
  end

  # -------------------------------------------------------------
  def feedback_poll
    @attempt = Attempt.find_by(id: params[:att_id])
    authorize! :read, @attempt
    @exercise_version = @attempt.exercise_version
    @exercise = @exercise_version.exercise
    respond_to do |format|
      format.js do
        render action:
          (@attempt.feedback_ready ? 'feedback_update' : 'feedback_poll')
      end
    end
  end

end
