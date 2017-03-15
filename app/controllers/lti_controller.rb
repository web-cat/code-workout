
class LtiController < ApplicationController
  require 'date'

  # load_and_authorize_resource
  after_action :allow_iframe, only: :launch

  def launch
    # must include the oauth proxy object
    require 'oauth/request_proxy/rack_request'

    if request.post?
      render :error and return unless lti_authorize!

      @lms_instance = LmsInstance.find_by consumer_key: params[:oauth_consumer_key]

      # Retrieve user information and sign in the user.

      # First check if we can find a user using the LtiIdentity
      lti_user_id = params[:user_id]
      @lti_identity = LtiIdentity.find_by(lms_instance: @lms_instance, lti_user_id: lti_user_id)
      if @lti_identity
        @user = @lti_identity.user
      else
        # If not, check both email parameters
        email = params[:lis_person_contact_email_primary]
        @user = User.find_by(email: params[:lis_person_contact_email_primary])
        if @user.blank?
          @user = User.find_by(email: params[:custom_canvas_user_login_id])
        else
      end

      # If this condition is true, it means we haven't found a user so far,
      # meaning we need to create a new one
      if @user.blank?
        @user = User.new(email: email, first_name: first_name, last_name: last_name)
        @user.skip_password_validation = true
        @user.save
        @lti_identity = LtiIdentity.new(user: @user, lms_instance: @lms_instance, lti_user_id: lti_user_id)
        @lti_identity.save
      else
        # We've found a user, so we'll check for incomplete fields and give them values
        # before proceeding
        if @user.first_name.blank?
          @user.first_name = params[:lis_person_name_given]
        end

        if @user.last_name.blank?
          @user.last_name = params[:lis_person_name_family]
        end

        if @user.lti_identity.blank?
          @lti_identity = LtiIdentity.new(user: @user, lms_instance: @lms_instance, lti_user_id: lti_user_id)
          @lti_identity.save
        end
      end

      # We have a user, sign them in
      sign_in @user

      # if @tp.context_instructor?
      #   @user.global_role = GlobalRole.instructor
      #   @user.save
      # end

      lms_id = @lms_instance.id
      assignment_id = params[:custom_canvas_assignment_id]
      lis_outcome_service_url = params[:lis_outcome_service_url]
      lis_result_sourcedid = params[:lis_result_sourcedid]
      lms_assignment_id = "#{lms_id}-#{assignment_id}"
      @workout_offering = WorkoutOffering.find_by lms_assignment_id: lms_assignment_id
      if @workout_offering.blank?
        # These params may or may not be specified by the instructor using the ToolConsumer.
        # If not specified, infer from other information provided.
        organization_slug = params[:custom_organization] || Organization.find_by(id: @lms_instance.organization_id).slug
        course_number = params[:custom_course_number] || params[:context_label].gsub(/[^a-zA-Z0-9 ]/, '')
        term_slug = params[:custom_term]
        coff_url = params[:custom_url] || nil
        course_name = params[:custom_course_name] || params[:context_title]

        course_slug = course_number.gsub(/[^a-zA-Z0-9]/, '').downcase
        coff_label = params[:custom_label] # This is required from the instructor in the ToolConsumer

        @organization = Organization.find_by(slug: organization_slug)
        if @organization.blank?
          @message = 'Organization not found.'
          render :error and return
        end

        @course = Course.find_by(number: course_number, organization: @organization) ||
          Course.find_by(slug: course_slug, organization: @organization)
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
            @message = 'Course offering not found. Please contact your instructor.'
            render :error and return
          end
        end

        if @course_offering.lms_instance.blank?
          @course_offering.lms_instance = @lms_instance
          @course_offering.save!
        end

        # Need to check instructor enrollment here so that permissions are
        # set for creating workouts (if the workout does not already
        # exist).
        if @tp.context_instructor? &&
          @course_offering &&
          @course_offering.can_enroll? &&
          !@course_offering.is_enrolled?(current_user)
          CourseEnrollment.create(
            course_offering: @course_offering,
            user: current_user,
            course_role: CourseRole.instructor
          )
        end

        workout_name = params[:resource_link_title]

        if (/\A[0-9][0-9].[0-9][0-9].[0-9][0-9] -/ =~ workout_name).nil?
          @workout = Workout.find_by(name: workout_name)
        else
          @workout = Workout.find_by(name: workout_name[11..workout_name.length])
        end

        if @workout.blank?
          if @tp.context_instructor?
            lti_params = {}
            lti_params[:lms_assignment_id] = lms_assignment_id
            lti_params[:lis_result_sourcedid] = lis_result_sourcedid
            lti_params[:lis_outcome_service_url] = lis_outcome_service_url
            session[:lti_params] = lti_params

            redirect_to organization_new_workout_path(
              lti_launch: true,
              course_id: @course.slug,
              term_id: @term.slug,
              organization_id: @organization.slug
            ) and return
          else
            @message = 'Workout not found. Please contact your instructor.'
            render :error and return
          end
        end

        @workout_offering = WorkoutOffering.find_by(
          course_offering_id: @course_offering.id,
          workout_id: @workout.id
        )
        if @workout_offering.blank?
          @workout_offering = WorkoutOffering.new(
            course_offering: @course_offering,
            workout: @workout,
            opening_date: DateTime.now,
            soft_deadline: nil,
            hard_deadline: nil,
            lms_assignment_id: lms_assignment_id
          )
          @workout_offering.save!
        else
          @workout_offering.lms_assignment_id = lms_assignment_id
          @workout_offering.save!
        end
      end

      # All pieces of information are ready, we are ready to display the workout_offering
      @workout = @workout_offering.workout
      @course_offering = @workout_offering.course_offering
      @term = @course_offering.term
      @course = @course_offering.course
      @organization = @course.organization

      # Users accessing the workout after it has been created will be enrolled here
      role = @tp.context_instructor? ? CourseRole.instructor : CourseRole.student

      if @tp.context_student? &&
        @course_offering &&
        @course_offering.can_enroll? &&
        !@course_offering.is_enrolled?(current_user)

        CourseEnrollment.create(
          course_offering: @course_offering,
          user: current_user,
          course_role: role
        )
      end

      redirect_to organization_workout_offering_practice_path(
        lis_outcome_service_url: lis_outcome_service_url,
        lis_result_sourcedid: lis_result_sourcedid,
        id: @workout_offering.id,
        organization_id: @organization.id,
        term_id: @term.id,
        course_id: @course.id,
        lti_launch: true
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
