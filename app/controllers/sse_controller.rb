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
    @exercise_version = @attempt.exercise_version
    @exercise = @exercise_version.exercise
    @max_points = ExerciseWorkout.find_by(exercise: @exercise, workout: @workout).andand.points

    if @workout_score = @attempt.workout_score
      @total_points = ExerciseWorkout.where(workout_id: @workout_score.workout_id).sum(:points)
      if lms_instance = @workout_score.workout_offering.course_offering.lms_instance
        key = lms_instance.consumer_key
        secret = lms_instance.consumer_secret

        @tp = IMS::LTI::ToolProvider.new(key, secret, {
          "lis_outcome_service_url" => "#{@workout_score.lis_outcome_service_url}",
          "lis_result_sourcedid" => "#{@workout_score.lis_result_sourcedid}"
        })
        @tp.post_replace_result!(@workout_score.score / @total_points)
      end
    end

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
    if !@attempt.feedback_ready
      render action: 'feedback_poll' and return
    else
      redirect_to action: 'feedback_update', att_id: params[:att_id] and return
    end
  end

end
