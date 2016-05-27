class LtiController < ApplicationController

  # load_and_authorize_resource
  after_action :allow_iframe, only: :launch
  # the consumer keys/secrets
  $oauth_creds = {"test" => "secret1"}

  def launch
    # must include the oauth proxy object
    require 'oauth/request_proxy/rack_request'

    if request.post?
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

      roles = params[:roles]
      number = params[:custom_number]
      course_name = params[:context_title]
      creator_id = @user.id

      @course = Course.find_by(number: number)
      if @course.blank?
        @course = Course.new(
          name: course_name,
          number: number,
          creator_id: @user.id
        )
        @course.save
      end

      @term = Term.current_term
      @course_offering = CourseOffering.find_by(course_id: @course.id, term_id: @term.id)
      if @course_offering.blank?
        @course_offering = CourseOffering.create(
          label: nil,
          url: nil,
          self_enrollment_allowed: 1,
          term: @term
        )
        @course.course_offerings << @course_offering
      end

      workout_name = params[:resource_link_title]
      @workout = Workout.find_by(name: workout_name)
      if @workout.blank?
        render 'Could not find workout', layout: 'error' and return
      else
        @workout_offering = WorkoutOffering.find_by(
          course_offering_id: @course_offering.id, term_id: @term.id
        )
        if @workout_offering.blank?
          render 'Could not find workout offering', layout: 'error' and return
        end
      end
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
