class WorkoutOfferingsController < ApplicationController
  skip_before_filter :authenticate_user!, :only => :practice

  load_and_authorize_resource

  skip_authorize_resource :only => :practice

  #~ Action methods ...........................................................
  after_action :allow_iframe, only: :practice

  # the consumer keys/secrets
  $oauth_creds = {"test" => "secret"}

  # -------------------------------------------------------------
  def show
    if @workout_offering
      @workout = @workout_offering.workout
      @course = Course.find params[:course_id]
      @term = Term.find params[:term_id]
      @organization = Organization.find params[:organization_id]
      @course_offering = CourseOffering.find_by course: @course, term: @term
      @exs = @workout.exercises
    end
    render 'workouts/show'
  end

  def review
    if @workout_offering
      @workout = @workout_offering.workout
      @exs = @workout.exercises
    end
    render 'workouts/review'
  end
  # --------------------------------------------------------------
  # Controller action to add an extension for a workout offering
  # to a student.
  def add_extension
    if params[:user_id] && student = User.find(params[:user_id]) &&
        workoutoffering = WorkoutOffering.find(params[:workout_offering_id])
      if params[:soft_deadline] && params[:hard_deadline]
        normalized_hard_deadline = params[:hard_deadline]
        normalized_soft_deadline = params[:soft_deadline]
        extension = StudentExtension.new(user: student, workout_offering: workoutoffering,
          hard_deadline: normalized_hard_deadline, soft_deadline: normalized_soft_deadline)
        if extension.save
          redirect_to root_path, notice: 'Extension success'
        else
          redirect_to root_path, notice: 'Failed to create extension'
        end
      else
        redirect_to root_path, notice: 'Both deadlines need to be specified' and return
      end
    else
      redirect_to root_path, notice: 'User not found' and return
    end
  end

  # -------------------------------------------------------------
  def practice
    # must include the oauth proxy object
    require 'oauth/request_proxy/rack_request'
    @lti_launch = params[:lti_launch]
    if @lti_launch
      lti_enroll
    end
    if @workout_offering
      unless current_user.andand.can? :practice, @workout_offering
        @message = 'You are not authorized to access that workout offering.'
        if !@workout_offering.published && 
            @workout_offering.course_offering.is_student?(current_user)
          @message = "#{@message} Your instructor has not yet published it."
        end

        if @lti_launch
          render 'lti/error' and return
        else
          flash[:error] = @message
          redirect_to root_path and return
        end
      end

      lis_outcome_service_url = params[:lis_outcome_service_url]
      lis_result_sourcedid = params[:lis_result_sourcedid]
      ex1 = nil
      if params[:exercise_id]
        ex1 = Exercise.find_by(id: params[:exercise_id])
        # FIXME: need to check that ex1 is actually in this workout
      end
      session[:current_workout] = @workout_offering.workout.id
      session[:workout_feedback] = Hash.new
      session[:workout_feedback]['workout'] =
        "You have attempted Workout #{@workout_offering.workout.name}"

      @workout_score = @workout_offering.score_for(current_user)

      should_force_lti = !@lti_launch &&
        @workout_offering.lms_assignment_id.present? &&
        (@workout_score.nil? ||
        @workout_score.lis_result_sourcedid.nil? ||
        @workout_score.lis_outcome_service_url.nil?)

      if should_force_lti && !current_user.manages?(@workout_offering.course_offering)
        @message = "This assignment must be accessed through your course's " +
          "Learning Management System (like Canvas)."
        @redirect_url = @workout_offering.lms_assignment_url
        render 'lti/error' and return
      end

      if current_user
        @workout_score = @workout_offering.score_for(current_user)
        if @workout_score.nil? && @workout_offering.can_be_practiced_by?(current_user)
          @workout_score = WorkoutScore.new(
            score: 0,
            exercises_completed: 0,
            exercises_remaining: @workout_offering.workout.exercises.length,
            user: current_user,
            workout_offering: @workout_offering,
            workout: @workout_offering.workout,
          )
          @workout_score.lis_outcome_service_url = lis_outcome_service_url
          @workout_score.lis_result_sourcedid = lis_result_sourcedid
          @workout_score.save!
        end
        current_user.current_workout_score = @workout_score
        current_user.save!
        if @workout_score.andand.closed? &&
          @workout_score.andand.workout_offering.andand.workout_policy.
          andand.no_review_before_close &&
          !@workout_score.andand.workout_offering.andand.shutdown?
          redirect_to organization_workout_offering_path(
            organization_id:
              @workout_offering.course_offering.course.organization.slug,
            course_id: @workout_offering.course_offering.course.slug,
            term_id: @workout_offering.course_offering.term.slug,
            id: @workout_offering.id),
            notice: "The time limit has passed for this workout." and return
        end
      end
      if ex1.nil?
        ex1 = @workout_offering.workout.first_exercise
      end
      if @workout_offering.course_offering.is_staff?(current_user) &&
          !@workout_offering.published &&
          (@workout_offering.opening_date.nil? || 
           @workout_offering.opening_date < DateTime.now)
        flash[:warning] = 'This workout offering is OPEN but currently ' +
          'UNPUBLISHED. It cannot be accessed by studennts.'
      end
      redirect_to organization_workout_offering_exercise_path(
        id: ex1.id,
        organization_id:
          @workout_offering.course_offering.course.organization.slug,
        course_id: @workout_offering.course_offering.course.slug,
        term_id: @workout_offering.course_offering.term.slug,
        workout_offering_id: @workout_offering.id,
        lis_result_sourcedid: lis_result_sourcedid,
        lis_outcome_service_url: lis_outcome_service_url,
        lti_launch: @lti_launch
      )
    else
      redirect_to root_path, notice: 'Workout offering not found' and return
    end
  end

  private

    def lti_enroll
      @workout_offering = WorkoutOffering.find_by(id: params[:id])
      @course_offering = @workout_offering.course_offering

      if @course_offering &&
        @course_offering.can_enroll? &&
        !@course_offering.is_enrolled?(current_user)

        CourseEnrollment.create(
        course_offering: @course_offering,
        user: current_user,
        course_role: CourseRole.student)
      end
    end

    def was_nonce_used_in_last_x_minutes?(nonce, minutes=60)
      # some kind of caching solution or something to keep a short-term memory of used nonces
      false
    end

    def lti_authorize!
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
        @message = "No consumer key"
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

end
