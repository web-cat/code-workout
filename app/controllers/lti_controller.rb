
class LtiController < ApplicationController
  require 'date'

  # load_and_authorize_resource
  after_action :allow_iframe, only: :launch

  def launch
    # must include the oauth proxy object
    require 'oauth/request_proxy/rack_request'

    if request.post?
      render :error and return unless lti_authorize!

      @lms_instance = LmsInstance.find_by(consumer_key: params[:oauth_consumer_key])

      @lti_identity = LtiIdentity.find_by(lms_instance: @lms_instance, lti_user_id: params[:user_id])

      # Get a new or existing user based on LTI params
      @user = User.lti_new_or_existing_user({
        lti_identity: @lti_identity,
        lis_person_contact_email_primary: params[:lis_person_contact_email_primary],
        custom_canvas_user_login_id: params[:custom_canvas_user_login_id],
        first_name: params[:lis_person_name_given],
        last_name: params[:lis_person_name_family]
      })

      # Check for incomplete fields and update with info from LMS if needed
      if @user.first_name.blank?
        @user.first_name = params[:lis_person_name_given]
      end

      if @user.last_name.blank?
        @user.last_name = params[:lis_person_name_family]
      end

      # Old users and newly created ones may not have an LtiIdentity set up
      if !@user.lti_identities.where(lms_instance: @lms_instance).andand.first
        @lti_identity = LtiIdentity.new(user: @user, lms_instance: @lms_instance, lti_user_id: params[:user_id])
        @lti_identity.save!
      end

      @user.save!

      # We have a user, sign them in
      sign_in @user

      @lms_instance = LmsInstance.find_by consumer_key: params[:oauth_consumer_key]

      @organization = @lms_instance.organization
      course_number = params[:custom_course_number] || params[:context_label].gsub(/[^a-zA-Z0-9 ]/, '')
      
      ext_lti_assignment_id = params[:ext_lti_assignment_id]
      custom_canvas_assignment_id = params[:custom_canvas_assignment_id]

      # Serving a public workout?
      lti_workout = LtiWorkout.find_by(lms_assignment_id: ext_lti_assignment_id) ||
        LtiWorkout.find_by(lms_assignment_id: custom_canvas_assignment_id)

      session[:lis_outcome_service_url] = params[:lis_outcome_service_url]
      session[:lis_result_sourcedid] = params[:lis_result_sourcedid]
      session[:lms_instance_id] = @lms_instance.id
      session[:is_instructor] = @tp.context_instructor?

      gym_workout_id = params[:custom_gym_workout_id] || params[:gym_workout_id]
      if !lti_workout && gym_workout_id 
        # First time this workout is being accessed from the
        # given LTI assignment
        workout = Workout.find_by(id: gym_workout_id)
        if !workout 
          # no workout found. different paths forward based on LTI role 
          if @tp.context_instructor?
            redirect_to new_or_existing_workout_path(
              lti_launch: true,
              lms_assignment_id: ext_lti_assignment_id
            ) and return
          else
            @message = 'The requested workout does not exist, and your role does
              permit you to create one. Please contact your
              instructor.'
            render :error and return
          end
        else
          # found a workout, setup LTI ties and continue
          # either students or instructors can do this 
          lti_workout = LtiWorkout.create(
            lms_assignment_id: ext_lti_assignment_id,
            workout: workout,
            lms_instance: @lms_instance
          )
        end
      end

      if lti_workout
        # Serving a public workout over LTI
        session.delete(:lis_outcome_service_url)
        session.delete(:lis_result_sourcedid)
        session.delete(:lms_instance_id)
        redirect_to practice_workout_path(
          id: lti_workout.workout_id,
          lti_launch: true,
          lti_workout_id: lti_workout.id,
          lis_outcome_service_url: params[:lis_outcome_service_url],
          lis_result_sourcedid: params[:lis_result_sourcedid]
        ) and return
      end

      # are we serving a workout from a pre-existing collection? (like OpenDSA)
      workout_from_collection = params[:from_collection]

      # Finding appropriate course offerings and workout offerings from the workout
      resource_link_title = params[:resource_link_title]
      if (/\A[0-9][0-9].[0-9][0-9].[0-9][0-9] -/ =~ resource_link_title).nil?
        workout_name = resource_link_title
      else
        workout_name = resource_link_title[11..resource_link_title.length]
        workout_from_collection = true
      end

      term_slug = params[:custom_term]
      course_name = params[:context_title]
      course_slug = course_number.gsub(/[^a-zA-Z0-9]/, '').downcase
      dynamic_lms_assignment = params[:dynamic].to_b

      if @organization.blank?
        @message = 'Organization not found'
        render 'lti/error' and return
      end

      @course = Course.find_by(slug: course_slug, organization: @organization)
      if !@course && !params[:custom_course_number]
        # Try searching again, assuming context label includes additional
        # junk following the course number
        course_number = params[:context_label].gsub(/[^a-zA-Z0-9 ]/, ' ').
          sub(/([0-9]+) .*$/, '\1').gsub(/\s+/, ' ')
        course_slug = course_number.gsub(/[^a-zA-Z0-9]/, '').downcase
        @course = Course.find_by(slug: course_slug, organization: @organization)
      end
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
          render 'lti/error' and return
        end
      end

      # TODO: Consider creating new terms as appropriate
      @term = Term.find_by(slug: term_slug) || Term.current_term
      if @term.blank?
        @message = 'Term not found.'
        render 'lti/error' and return
      end

      redirect_to organization_find_workout_offering_path(
        organization_id: @organization.slug,
        term_id: @term.slug,
        workout_name: workout_name,
        user_id: @user.id,
        course_id: @course.slug,
        ext_lti_assignment_id: ext_lti_assignment_id,
        custom_canvas_assignment_id: custom_canvas_assignment_id,
        dynamic_lms_assignment: dynamic_lms_assignment,
        lms_instance_id: @lms_instance.id,
        label: params[:custom_label], # can be nil
        lis_outcome_service_url: params[:lis_outcome_service_url],
        lis_result_sourcedid: params[:lis_result_sourcedid],
        from_collection: workout_from_collection
      )
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
