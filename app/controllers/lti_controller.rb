class LtiController < ApplicationController
  require 'date'

  # load_and_authorize_resource
  after_action :allow_iframe, only: :launch
  # the consumer keys/secrets
  # $oauth_creds = {"test" => "secret"}

  #TODO massive refactoring required -- try to reduce the number of queries needed
  def launch
    # must include the oauth proxy object
    require 'oauth/request_proxy/rack_request'

    if request.post?
      render :error and return unless lti_authorize!

      # Retrieve user information and sign in the user.
      email = params[:lis_person_contact_email_primary]
      first_name = params[:lis_person_name_given]
      last_name = params[:lis_person_name_family]
      @user = User.where(email: email).first
      if @user.blank?
        @user = User.new(email: email, password: email, password_confirmation: email,
          first_name: first_name, last_name: last_name)
        @user.save
      end
      sign_in @user

      @lms_instance = LmsInstance.find_by consumer_key: params[:oauth_consumer_key]
      lms_id = @lms_instance.id
      assignment_id = params[:custom_canvas_assignment_id]
      lms_assignment_id = "#{lms_id}-#{assignment_id}"
      @workout_offering = WorkoutOffering.find_by lms_assignment_id: lms_assignment_id

      if @workout_offering.blank?
        # These two params may or may not specified by the instructor in the ToolConsumer.
        # If not specified, infer from other information provided.
        organization_slug = params[:custom_organization] || Organization.find_by(id: @lms_instance.organization_id).slug
        course_number = params[:custom_course_number] || params[:context_label].gsub(/[^a-zA-Z0-9 ]/, '')
        term_slug = params[:custom_term]

        course_slug = course_number.gsub(/[^a-zA-Z0-9]/, '').downcase
        course_name = params[:context_title]
        coff_label = params[:custom_label] # This is required from the instructor in the ToolConsumer
        coff_url = params[:custom_url] || nil

        @organization = Organization.find_by(slug: organization_slug)
        if @organization.blank?
          @message = 'Organization not found.'
          render :error and return
        end

        @course = Course.find_by(number: course_number) || Course.find_by(slug: course_slug)
        if @course.blank?
          if @tp.context_instructor?
            @course = Course.new(
              name: course_name,
              number: course_number,
              creator_id: @user.id,
              organization_id: @organization.id,
              slug: course_slug
            )
            @organization.courses << @course
            @course.save
          else
            @message = 'Course not found.'
            render :error and return
          end
        end

        @term = Term.find_by(slug: term_slug) || Term.current_term
        if @term.blank?
          @message = 'Term not found.'
          render :error and return
        end

        @course_offering = CourseOffering.find_by course_id: @course.id, term_id: @term.id, label: coff_label
        if @course_offering.blank?
          if @tp.context_instructor?
            @course_offering = CourseOffering.new(
              label: coff_label,
              url: coff_url,
              self_enrollment_allowed: 1,
              course: @course,
              term: @term,
              lms_instance: @lms_instance
            )
            @course_offering.save!
            @course.course_offerings << @course_offering
            @course.save!
          else
            @message = 'Course offering not found.'
            render :error and return
          end
        end

        if @course_offering.lms_instance.blank?
          @course_offering.lms_instance = @lms_instance
          @course_offering.save!
        end

        course_role = 'tmp'
        if @tp.context_instructor?
          course_role = CourseRole.instructor
        elsif @tp.context_student?
          course_role = CourseRole.student
        end

        if @course_offering &&
          @course_offering.can_enroll? &&
          !@course_offering.is_enrolled?(current_user)
          CourseEnrollment.create(
            course_offering: @course_offering,
            user: current_user,
            course_role: course_role
          )
        end

        workout_name = params[:resource_link_title]
        @workout = Workout.find_by(name: workout_name)
        if @workout.blank?
          # session[:lms_assignment_id] = lms_assignment_id
          # session[:from_lti] = true
          # redirect_to '/gym/workouts/new'
          @message = 'Workout not found. Please contact your instructor.'
          render :error and return
        end

        @workout_offering = WorkoutOffering.find_by(
          course_offering_id: @course_offering.id,
          workout_id: @workout.id
        )
        if @workout_offering.blank?
          if @tp.context_instructor?
            @workout_offering = WorkoutOffering.new(
              course_offering: @course_offering,
              workout: @workout,
              opening_date: DateTime.now,
              soft_deadline: @term.ends_on,
              hard_deadline: @term.ends_on,
              lms_assignment_id: lms_assignment_id
            )
            @workout_offering.save!
          else
            @message = 'Workout Offering not found. Please contact your instructor.'
            render :error and return
          end
        end
      end

      # All pieces of information are ready, ready to display the workout_offering
      @workout ||= @workout_offering.workout
      @course_offering ||= @workout_offering.course_offering
      @term ||= @course_offering.term
      @course ||= @course_offering.course
      @organization ||= @course.organization

      ex1 = nil
      if params[:exercise_id]
        ex1 = Exercise.find_by(id: params[:exercise_id])
      end
      if current_user
        lis_outcome_service_url = params[:lis_outcome_service_url]
        lis_result_sourcedid = params[:lis_result_sourcedid]
        @workout_score = @workout_offering.score_for(current_user)
        if @workout_score.nil?
          @workout_score = WorkoutScore.new(
            score: 0,
            exercises_completed: 0,
            exercises_remaining: @workout.exercises.length,
            user: current_user,
            workout_offering: @workout_offering,
            workout: @workout,
            lis_outcome_service_url: lis_outcome_service_url,
            lis_result_sourcedid: lis_result_sourcedid)
          @workout_score.save!
        end
        current_user.current_workout_score = @workout_score
        current_user.save!
        if @workout_score.andand.closed? &&
          @workout_score.andand.workout_offering.andand.workout_policy.
          andand.no_review_before_close &&
          !@workout_score.andand.workout_offering.andand.shutdown?
          redirect_to organization_workout_offering_path(
            organization_id: @organization.slug,
            course_id: @course.slug,
            term_id: @term.slug,
            id: @workout_offering.id,
            tp: @tp),
            notice: "The time limit has passed for this workout." and return
        end
      end
      if ex1.nil?
        ex1 = @workout_offering.workout.next_exercise(
          nil, current_user, @workout_score)
      end
      redirect_to organization_workout_offering_exercise_path(
        id: ex1.id,
        organization_id: @workout_offering.course_offering.course.organization.slug,
        course_id: @workout_offering.course_offering.course.slug,
        term_id: @workout_offering.course_offering.term.slug,
        workout_offering_id: @workout_offering.id,
        tp: @tp)
    end
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
      @message = "This tool wasn't launched as an outcome service"
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
    def lti_authorize!
      if key = params['oauth_consumer_key']
        if secret = LmsInstance.find_by(consumer_key: key).andand.consumer_secret
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
