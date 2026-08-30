class WorkoutOfferingsController < ApplicationController
  # Isn't this handled by authorize_resource already?
  # skip_before_action :authenticate_user!, :only => :practice

  before_action :resolve_section_offering, only: [:show, :practice, :review]
  load_and_authorize_resource
  skip_authorize_resource :only => :practice

  #~ Action methods ...........................................................
  after_action :allow_iframe, only: :practice


  # --------------------------------------------------------------
  # /courses/:organization_id/:course_id/:term_id/:id
  def show
    if @workout_offering
      @workout = @workout_offering.workout
      @course_offering = @workout_offering.course_offering
      @course = @course_offering.andand.course
      @term = @course_offering.andand.term
      @organization = @course.andand.organization
      @exs = @workout ? @workout.exercises.includes(
        :tags,
        :taggings,
        :languages,
        current_version: :prompts
      ) : []
      @workout_score = @workout_offering.score_for(current_user)

      if @workout_score
        @scoring_attempts_by_version_id = @workout_score.scored_attempts.group_by(&:exercise_version_id)
      elsif current_user
        exercise_version_ids = @exs.map(&:current_version_id).compact
        if exercise_version_ids.any?
          @attempts_by_version_id = Attempt.where(
            user_id: current_user.id,
            exercise_version_id: exercise_version_ids,
            workout_score_id: nil
          ).order(submit_time: :desc).group_by(&:exercise_version_id)
        else
          @attempts_by_version_id = {}
        end
      end
    end
    render 'workouts/show'
  end


  # --------------------------------------------------------------
  def review
    if @workout_offering
      @workout = @workout_offering.workout
      @course_offering = @workout_offering.course_offering
      @course = @course_offering.andand.course
      @term = @course_offering.andand.term
      @organization = @course.andand.organization
      @exs = @workout.andand.exercises || []
      review_user = params[:review_user_id] ? User.find_by(id: params[:review_user_id]) : current_user
      @workout_score = @workout_offering.score_for(review_user)

      if @workout_score
        @scoring_attempts_by_version_id = @workout_score.scored_attempts.group_by(&:exercise_version_id)
      end
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
          'UNPUBLISHED. It cannot be accessed by students.'
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


  # --------------------------------------------------------------
  def activity_log
    @workout_offering = WorkoutOffering.find(params[:id])
    @course_offering = @workout_offering.course_offering

    # Access control
    unless current_user.global_role.is_admin? || @course_offering.is_staff?(current_user)
      redirect_to root_path, notice: 'You are not authorized to view this page.' and return
    end

    @workout_score = WorkoutScore.find(params[:workout_score_id])
    @student = @workout_score.user
    @exercise_id = params[:exercise_id]
    @exercise = Exercise.find_by(id: @exercise_id) if @exercise_id.present?

    # Fetch events
    @activity_logs = ActivityLog.where(workout_score: @workout_score)
    @attempts = Attempt.where(workout_score: @workout_score)
    @visualization_loggings = VisualizationLogging.where(workout_score: @workout_score)

    if @exercise_id.present?
      @activity_logs = @activity_logs.where(exercise_id: @exercise_id)
      @attempts = @attempts.joins(:exercise_version).where(exercise_versions: { exercise_id: @exercise_id })
      @visualization_loggings = @visualization_loggings.where(exercise_id: @exercise_id)
    end

    # Combine and sort events
    @events = []

    @activity_logs.each do |log|
      @events << {
        type: 'activity',
        time: log.created_at,
        activity: log.activity,
        ip: log.ip_address,
        lti: log.lti_launch,
        details: log
      }
    end

    @attempts.each do |attempt|
      @events << {
        type: 'attempt',
        time: attempt.submit_time,
        activity: 'evaluated',
        score: attempt.score,
        ip: attempt.ip_address,
        lti: attempt.lti_launch,
        details: attempt
      }
    end

    @visualization_loggings.each do |log|
      @events << {
        type: 'visualization',
        time: log.created_at,
        activity: 'visualized',
        ip: log.ip_address,
        lti: log.lti_launch,
        details: log
      }
    end

    @events.sort_by! { |e| e[:time] }.reverse!
  end


  # --------------------------------------------------------------
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

    def resolve_section_offering
      return unless params[:id].present?

      @workout_offering = WorkoutOffering.includes(
        :workout_policy,
        :student_extensions,
        workout: [
          :tags,
          :owners,
          :exercise_workouts,
          { exercises: :current_version },
          { workout_offerings: { course_offering: :course_enrollments } }
        ],
        course_offering: [:term, { course: :organization }, :course_enrollments]
      ).find_by(id: params[:id])
      return unless @workout_offering

      course_offering = @workout_offering.course_offering
      return unless course_offering && current_user

      # If current_user is already enrolled or staff in this section, proceed normally
      return if course_offering.is_staff?(current_user) || course_offering.is_enrolled?(current_user)

      # Check if current_user is enrolled in a sibling section for the same course and term
      enrolled_offerings = current_user.course_offerings_for_term(course_offering.term, course_offering.course)
      if enrolled_offerings.any?
        sister_offering = WorkoutOffering.where(
          course_offering_id: enrolled_offerings.map(&:id),
          workout_id: @workout_offering.workout_id
        ).first

        if sister_offering
          target_path = case action_name
          when 'practice'
            organization_workout_offering_practice_path(
              organization_id: sister_offering.course_offering.course.organization.slug,
              course_id: sister_offering.course_offering.course.slug,
              term_id: sister_offering.course_offering.term.slug,
              id: sister_offering.id,
              exercise_id: params[:exercise_id],
              lti_launch: params[:lti_launch]
            )
          when 'review'
            organization_workout_offering_review_path(
              organization_id: sister_offering.course_offering.course.organization.slug,
              course_id: sister_offering.course_offering.course.slug,
              term_id: sister_offering.course_offering.term.slug,
              id: sister_offering.id,
              review_user_id: params[:review_user_id] || current_user.id
            )
          else
            organization_workout_offering_path(
              organization_id: sister_offering.course_offering.course.organization.slug,
              course_id: sister_offering.course_offering.course.slug,
              term_id: sister_offering.course_offering.term.slug,
              id: sister_offering.id
            )
          end
          redirect_to target_path and return
        end
      end
    end

    def was_nonce_used_in_last_x_minutes?(nonce, minutes=60)
      # some kind of caching solution or something to keep a short-term memory of used nonces
      false
    end

end
