class SseController < ApplicationController
  include ActionController::Live
  require 'ims/lti'
  require 'oauth/request_proxy/rack_request'

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
    @attempts_exhausted = params[:attempts_exhausted].to_b
    @exercise_version = @attempt.exercise_version
    @exercise = @exercise_version.exercise
    @max_points = @exercise.experience
    @student_drift_user =  current_user ? current_user : session[:drift_user_id]
    workout_score = @attempt.workout_score
    if workout_score
      @workout = workout_score.workout
      @max_points = @workout.exercise_workouts.where(exercise: @exercise).
        first.points
    end

    respond_to do |format|
      format.js
    end
  end

  # -------------------------------------------------------------
  def feedback_poll
    @attempt = Attempt.find_by(id: params[:att_id])
    @exercise_version = @attempt.exercise_version
    @student_drift_user = current_user ? current_user : session[:student_drift_user_id]? User.find_by(session[:student_drift_user_id]) : User.find_by(params[:drift_user_id])
    @exercise = @exercise_version.exercise
    # authorize! :read, @attempt
    if !@attempt.feedback_ready
      respond_to do |format|
        format.js
      end
    else
      redirect_to action: 'feedback_update', 
        att_id: params[:att_id],
        attempts_exhausted: params[:attempts_exhausted] and return
    end
  end

end
