class LtiController < ApplicationController


  after_action :allow_iframe, only: :launch
  # the consumer keys/secrets
  $oauth_creds = {"test" => "secret"}

  def launch
    # must include the oauth proxy object
    require 'oauth/request_proxy/rack_request'

    render('error') and return unless authorize!

    if params[:exercise_version_id]
      @exercise_version =
        ExerciseVersion.find_by(id: params[:exercise_version_id])
      if !@exercise_version
        redirect_to exercises_url, notice:
          "Exercise version EV#{params[:exercise_version_id]} " +
          "not found" and return
      end
      @exercise = @exercise_version.exercise
    elsif params[:id]
      @exercise = Exercise.find_by(id: params[:id])
      if !@exercise
        redirect_to exercises_url,
          notice: "Exercise E#{params[:id]} not found" and return
      end
      @exercise_version = @exercise.current_version
    else
      redirect_to exercises_url,
        notice: 'Choose an exercise to practice!' and return
    end
    # Tighter restrictions for the moment, should go away
    # authorize! :practice, @exercise

    @student_user = params[:review_user_id] ? User.find(params[:review_user_id]) : current_user

    if params[:workout_offering_id]
      @workout_offering =
        WorkoutOffering.find_by(id: params[:workout_offering_id])
      @workout = @workout_offering.workout
      if @workout_offering.time_limit_for(@student_user)
        @user_time_limit = @workout_offering.time_limit_for(@student_user)
      else
        @user_time_limit = nil
      end
    else
      @workout_offering = nil
      if params[:workout_id]
        @workout = Workout.find(params[:workout_id])
      end
    end

    @attempt = nil
    @workout_score = @workout_offering ? @student_user.current_workout_score :
      @workout ? @workout.score_for(@student_user, @workout_offering) : nil
    if @workout_offering &&
      @workout_score.workout_offering != @workout_offering
      @workout_score = nil
    end
    if @workout_offering && !@workout_score
      @workout_score = @workout_offering.score_for(@student_user)
    end
    if @workout_score
      @attempt = @workout_score.attempt_for(@exercise_version.exercise)
    end
    @workout ||= @workout_score ? @workout_score.workout : nil
    if @workout_score.andand.closed? &&
      @workout_offering.andand.workout_policy.andand.no_review_before_close &&
      !@workout_offering.andand.shutdown?
      path = root_path
      if @workout_offering
        path = organization_workout_offering_path(
            organization_id:
              @workout_offering.course_offering.course.organization.slug,
            course_id: @workout_offering.course_offering.course.slug,
            term_id: @workout_offering.course_offering.term.slug,
            workout_offering_id: @workout_offering.id)
      elsif @workout
        path = workout_path(@workout)
      end
      redirect_to path,
        notice: "The time limit has passed for this workout." and return
    end

    if @workout.andand.exercise_workouts.andand.where(exercise: @exercise).andand.any?
      @max_points = @workout.exercise_workouts.
        where(exercise: @exercise).first.points
      puts "\nMAX-POINTS", @max_points, "\nMAX-POINTS"
    end


    @responses = ['There are no responses yet!']
    @explain = ['There are no explanations yet!']
    if session[:leaf_exercises]
      session[:leaf_exercises] << @exercise.id
    else
      session[:leaf_exercises] = [@exercise.id]
    end
    # EOL stands for end of line
    # @wexs is the variable to hold the list of exercises of this workout
    # yet to be attempted by the user apart from the current exercise

    if params[:wexes] != 'EOL'
      @wexs = params[:wexes] || session[:remaining_wexes]
    else
      @wexs = nil
    end

    # render layout: 'two_columns'
    render template: "exercises/practice"

    # @section_html = File.read(File.join('public/OpenDSA/Books', params["book_folder_name"], '/lti_html/', "#{params['section_file_name'].to_s}.html")) and return
  end

  def assessment
    request_params = JSON.parse(request.body.read.to_s)
    launch_params = request_params['launch_params']
    if launch_params
      key = launch_params['oauth_consumer_key']
    else
      @message = "The tool never launched"
      render(:error)
    end

    @tp = IMS::LTI::ToolProvider.new(key, $oauth_creds[key], launch_params)

    if !@tp.outcome_service?
      @message = "This tool wasn't lunched as an outcome service"
      render(:error)
    end

    # post the given score to the TC
    score = (request_params['score'] != '' ? request_params['score'] : nil)
    res = @tp.post_replace_result!(score)

    if res.success?
      # @score = request_params['score']
      # @tp.lti_msg = "Message shown when arriving back at Tool Consumer."
      render :json => { :message => 'success' }.to_json
      # erb :assessment_finished
    else
      render :json => { :message => 'failure' }.to_json
      # @tp.lti_errormsg = "The Tool Consumer failed to add the score."
      # show_error "Your score was not recorded: #{res.description}"
      # return erb :error
    end
  end

  private
    def authorize!
      if key = params['oauth_consumer_key']
        if secret = $oauth_creds[key]
          @tp = IMS::LTI::ToolProvider.new(key, secret, params)
        else
          @tp = IMS::LTI::ToolProvider.new(nil, nil, params)
          @tp.lti_msg = "Your consumer didn't use a recognized key."
          @tp.lti_errorlog = "You did it wrong!"
          @message = "Consumer key wasn't recognized"
          return false
        end
      else
        render("No consumer key")
        return false
      end

      if !@tp.valid_request?(request)
        @message = "The OAuth signature was invalid"
        return false
      end

      if Time.now.utc.to_i - @tp.request_oauth_timestamp.to_i > 60*60
        @message = "Your request is too old."
        return false
      end

      # this isn't actually checking anything like it should, just want people
      # implementing real tools to be aware they need to check the nonce
      if was_nonce_used_in_last_x_minutes?(@tp.request_oauth_nonce, 60)
        @message = "Why are you reusing the nonce?"
        return false
      end

      # @username = @tp.username("Dude")
      return true
    end

    def allow_iframe
      response.headers.except! 'X-Frame-Options'
    end

    def was_nonce_used_in_last_x_minutes?(nonce, minutes=60)
      # some kind of caching solution or something to keep a short-term memory of used nonces
      false
    end

end