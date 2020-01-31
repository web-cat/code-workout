require 'json'
require 'date'
require 'wannabe_bool'

class WorkoutsController < ApplicationController
  include ArrayHelper

  before_action :set_workout, only: [
    :show,
    :update,
    :destroy,
    :download_attempt_data
  ]
  after_action :allow_iframe, only: [
    :new,
    :clone,
    :new_create,
    :edit,
    :embed,
    :find_offering,
    :new_or_existing
  ]
  respond_to :html, :js

  #~ Action methods ...........................................................

  # -------------------------------------------------------------
  # GET /workouts
  def index
    # if cannot? :index, Workout
    #   redirect_to root_path,
    #     notice: 'Unauthorized to view all workouts' and return
    # end
    @workouts = Workout.where(is_public: true)
    @gym = []
  end


  # -------------------------------------------------------------
  # GET /workouts/download.json
  def download
    if cannot? :index, Workout
      redirect_to root_path,
        notice: 'Unauthorized to view all workouts' and return
    end
    @workouts = Workout.accessible_by(current_ability)
    respond_to do |format|
      format.json do
        render text:
          WorkoutRepresenter.for_collection.new(@workouts).to_hash.to_json
      end
      format.yml do
        render text:
          WorkoutRepresenter.for_collection.new(@workouts).to_hash.to_yaml
      end
    end
  end


  # -------------------------------------------------------------
  def download_attempt_data
    if cannot? :edit, @workout
      redirect_to gym_path, flash: {
        error: 'You do not have permission to download data for this workout.'
      } and return
    end

    # FIXME: blatantly copied from exercises_controller, but should be
    # refactored to eliminate duplication
    @exs = @workout.exercises
    exercise_attributes = %w{ exercise_id exercise_name }
    attempt_attributes = %w{ user_id exercise_version_id version_no answer_id
      answer error attempt_id submit_time submit_num score workout_score
      workout_name course_number course_name term}
    data = CSV.generate(headers: true) do |csv|
      csv << (exercise_attributes + attempt_attributes)
      @exs.each do |ex|
        ex.attempt_data(@workout.id).each do |submission|
          csv << ([ @exercise.id, @exercise.name ] +
            attempt_attributes.map { |a| submission.attributes[a] })
        end
      end
    end

    respond_to do |format|
      format.csv do
        send_data data, filename: "workout-#{params[:id]}-submissions.csv"
      end
    end
  end


  # -------------------------------------------------------------
  # GET /workouts/1
  def show
    if cannot? :read, @workout
      redirect_to gym_path, flash: {
        error: 'You do not have permission to access that non-public workout.
          Have a look at these popular workouts instead.'
      } and return
    end
    @exs = @workout.exercises
  end


  # -------------------------------------------------------------
  def embed
		if params[:workout_id].present?
			@workout = Workout.find_by(id: params[:workout_id])
		elsif params[:resource_name].present?
			workouts = Workout.where('lower(name) = ? and is_public = true',
			  params[:resource_name].downcase)
			@workout = workouts.first
    end
 
    if @workout.andand.is_public
        redirect_to practice_workout_path(
          id: @workout.id,
          lti_launch: true) and return
    else
      @message = 'Sorry, there are no public workouts with that name or id.'
      render 'lti/error' and return
    end
  end


  # -------------------------------------------------------------
  def review
    @exs = @workout.exercises
  end


  # -------------------------------------------------------------
  # GET /gym
  def gym
    @gym = Workout.where(is_public: true).order('created_at DESC').
      limit(12)
    # render layout: 'two_columns'
  end


  # -------------------------------------------------------------
  # GET /workouts/new
  def new
    @lti_launch = params[:lti_launch]
    @workout = Workout.new
    @course = params[:course_id] ? Course.find(params[:course_id]) : nil

    @message = 'Unauthorized to create new workout'

    if @course
      # If there's a course, use role-based permissions from abilities.rb
      if cannot? :new, Workout
        redirect_to root_path,
          notice: @message and return
      end
      @term = params[:term_id] ? Term.find(params[:term_id]) : nil
      @organization = params[:organization_id] ? 
        Organization.find(params[:organization_id]) : nil
      @course_offerings = current_user.managed_course_offerings(
        course: @course, term: @term)
    elsif !session[:is_instructor]
      # If there's no course, use session-specific permissions 
      if @lti_launch
        render 'lti/error' and return
      else
        redirect_to root_path,
          notice: @message and return
      end
    end

    @lms_assignment_id = params[:lms_assignment_id]
    @lms_instance_id = params[:lms_instance_id]
    @suggested_name = params[:suggested_name]

    if params[:notice]
      flash.now[:notice] = params[:notice]
    end

    render layout: 'two_columns'
  end

  def new_or_existing
    @lti_launch = params[:lti_launch]
    @course = !!params[:course_id] ? Course.find(params[:course_id]) : nil

    # If there is a course, check course roles (in the ability file)
    # If there is no course, check LTI launch roles
    @can_create = (@course && can?(:new, Workout)) || session[:is_instructor]

    if !@can_create
      flash.now[:notice] = 
        'You are unauthorized to create new workouts. Choose from existing workouts instead.'
    end

    @term = !!params[:term_id] ? Term.find(params[:term_id]) : nil
    @organization = !!params[:organization_id] ? 
      Organization.find(params[:organization_id]) : nil
    @suggested_name = params[:suggested_name]

    @lms_assignment_id = params[:lms_assignment_id]
    
    # if course is specified, we want to highlight existing workouts that have 
    # been used in the given course before
    @searching_offerings = !!@course
    
    # we are finding or creating a workout for a course_offering
    if @course
      @new_workout_path = organization_new_workout_path(
        lti_launch: @lti_launch,
        organization_id: @organization.slug,
        term_id: @term.slug,
        lms_assignment_id: @lms_assignment_id,
        suggested_name: @suggested_name
      )

      @workout_offerings = @course.course_offerings.joins(:workout_offerings, :term)
        .order('terms.ends_on DESC')
        .flat_map(&:workout_offerings)

      # workouts_with_term is of the form [[CourseOffering, WorkoutOffering],
      # [CourseOffering, WorkoutOffering], [CourseOffering, WorkoutOffering]]
      # we will convert it into a Hash where each key is a term, and each value
      # is an array of Workouts
      workouts_with_term = @workout_offerings.map { |wo|
        [wo.course_offering.term, wo]
      }.group_by(&:first).map{ |k, a| [k, a.map(&:last)] }

      @default_results = array_to_hash(workouts_with_term)

      # make sure each term shows unique Workouts
      @default_results.each do |term, workout_offerings|
        @default_results[term] = workout_offerings.uniq{ |wo| wo.workout }
      end
    else 
      @new_workout_path = new_workout_path(
        lms_assignment_id: @lms_assignment_id,
        suggested_name: @suggested_name,
        lti_launch: @lti_launch
      )
    end

    render layout: 'one_column'
  end


  # -------------------------------------------------------------
  # GET /workouts/new_with_search/:searchkey
  def new_with_search
    @workout = Workout.new
    @exers = Exercise.find_by_sql(
      "SELECT * FROM exercises WHERE name LIKE '%#{params[:searchkey]}%'")
  end


  # -------------------------------------------------------------
  # POST /gym/workouts/search
  def search
    terms = escape_javascript(params[:search])
    terms = terms.split(terms.include?(' ') ? /\s*,\s*/ : nil)
    @course = params[:course] ? Course.find(params[:course]) : nil
    searching_offerings = params[:offerings]
    @workouts = Workout.search terms, current_user, @course, searching_offerings
    @lms_assignment_id = params[:lms_assignment_id]

    if @workouts.blank?
      @msg = 'Your search did not match any workouts. Try these instead...'
      @workouts = Workout.search nil, current_user, @course, searching_offerings

      if @workouts.blank?
        @msg = 'No public workouts exist yet. Please wait for contributors to add more.'
      end
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit
    @lti_launch = params[:lti_launch]
    if params[:workout_offering_id]
      # route is /courses/vt/:course_id/:term_id/:workout_offering_id/edit_workout/
      @workout_offering = WorkoutOffering.find(params[:workout_offering_id])
      @workout = @workout_offering.workout
    else
      @workout = Workout.find(params[:id]) 
    end

    if cannot? :edit, @workout
      redirect_to root_path,
        notice: 'You are not authorized to edit this workout.' and return
    end
    
    if @workout_offering 
      # we are editing a workout along with its workout offerings
      @course = Course.find(params[:course_id])
      @term = Term.find(params[:term_id])
      @organization = Organization.find params[:organization_id]
      @time_limit = @workout_offering.andand.time_limit
      @attempt_limit = @workout_offering.andand.attempt_limit
      @published = @workout_offering.andand.published
      @most_recent = @workout_offering.andand.most_recent
      @policy = @workout_offering.andand.workout_policy

      @workout_offerings = current_user.managed_workout_offerings_in_term(
        @workout, @course, @term).flatten

      course_offerings = current_user.managed_course_offerings(
        course: @course, term: @term)
      used_course_offerings = @workout_offerings.flat_map(&:course_offering)
      @unused_course_offerings = course_offerings - used_course_offerings

      @student_extensions = []
      @workout_offerings.each do |workout_offering|
        workout_offering.student_extensions.each do |e|
          ext = {}
          ext[:id] = e.id
          ext[:student_id] = e.user.id
          ext[:student_display] = e.user.display_name
          ext[:course_offering_id] = e.workout_offering.course_offering_id
          ext[:course_offering_display] =
            e.workout_offering.course_offering.display_name_with_term
          ext[:opening_date] = e.opening_date.andand.to_i
          ext[:soft_deadline] = e.soft_deadline.andand.to_i
          ext[:hard_deadline] = e.hard_deadline.andand.to_i
          ext[:time_limit] = e.time_limit
          @student_extensions.push(ext)
        end
      end
    end

    @can_update = can? :edit, @workout
    
    # exercises for the workout, to populate the form
    @exercises = []
    @workout.exercise_workouts.each do |ex|
      ex_data = {}
      ex_data[:name] = ex.exercise.name
      ex_data[:points] = ex.points
      ex_data[:id] = ex.exercise_id
      ex_data[:exercise_workout_id] = ex.id
      @exercises.push(ex_data)
    end

    render layout: 'two_columns'
  end


  # -------------------------------------------------------------
  def clone
    @workout = params[:id] ? Workout.find(params[:id]) : Workout.find(params[:workout_id])

    if current_user
      message = 'You are not authorized to clone that workout.'
    else
      message = 'You must be signed in to clone workouts.'
    end

    @lti_launch = params[:lti_launch]
    @lms_assignment_id = params[:lms_assignment_id]

    authorize! :clone, @workout, message: message

    if params[:lms_instance_id].present?
      lti_workout = LtiWorkout.create(
        lms_assignment_id: @lms_assignment_id,
        workout: @workout,
        lms_instance: LmsInstance.find(params[:lms_instance_id])
      )
      lis_outcome_service_url = session[:lis_outcome_service_url]
      session.delete(:lis_outcome_service_url)
      lis_result_sourcedid = session[:lis_result_sourcedid]
      session.delete(:lis_result_sourcedid)
      redirect_to practice_workout_path(
        id: @workout.id,
        lti_launch: @lti_launch,
        lti_workout_id: lti_workout.id,
        lis_outcome_service_url: lis_outcome_service_url,
        lis_result_sourcedid: lis_result_sourcedid
      ) and return
    end

    @suggested_name = params[:suggested_name]
    @exercises = []
    @workout.exercise_workouts.each do |ex|
      ex_data = {}
      ex_data[:name] = ex.exercise.name
      ex_data[:points] = ex.points
      ex_data[:id] = ex.exercise_id
      ex_data[:exercise_workout_id] = ex.id
      @exercises.push(ex_data)
    end
    
    if params[:course_id]
      @course = Course.find params[:course_id]
      @term = Term.find params[:term_id]
      @can_update = can? :edit, @workout
      @time_limit = @workout.workout_offerings.first.andand.time_limit
      @organization = Organization.find params[:organization_id]
      @course_offerings =
        current_user.andand.managed_course_offerings(course: @course, term: @term)
      @unused_course_offerings = nil
    end

    render layout: 'two_columns'
  end


  # -------------------------------------------------------------
  def create
    @workout = Workout.new
    @workout.creator_id = current_user.id
    @lti_launch = params[:lti_launch]
    workout_params = {
      name: params[:name],
      description: params[:description],
      is_public: params[:is_public],
      removed_exercises: params[:removed_exercises],
      exercises: params[:exercises]
    }
    
    course = params[:course_id]
    if course.blank?
      # no course, so this workout needs to manage its own LTI ties 
      workout_params[:lms_assignment_id] = params[:lms_assignment_id]
      workout_params[:lms_instance_id] = session[:lms_instance_id]
    end
    @workout = @workout.update_or_create(workout_params)

    if @workout && course.present?
      workout_offering_id = create_or_update_offerings(@workout)
      if workout_offering_id
        lti_params = session[:lti_params]
        url = url_for(organization_workout_offering_path(
            organization_id: params[:organization_id],
            course_id: params[:course_id],
            term_id: params[:term_id],
            id: workout_offering_id,
            lti_launch: @lti_launch 
          )
        )
      else
        url = url_for(practice_workout_path(id: @workout.id))
      end
    elsif !@workout
      err_string = 'There was a problem while creating the workout.'
      url = url_for(root_path(notice: err_string)) 
    else
      session.delete(:lis_result_sourcedid)      
      session.delete(:lis_outcome_service_url)
      url = url_for(practice_workout_path(
        id: @workout.id,
        lti_launch: @lti_launch
      ))
    end 

    respond_to do |format|
      format.json { render json: { url: url } }
    end
  end


  # -------------------------------------------------------------
  def find_offering
    @user = User.find params[:user_id]
    @term = Term.find params[:term_id]
    @course = Course.find params[:course_id]
    @lti_launch = true
    dynamic_lms_assignment = params[:dynamic_lms_assignment]
    ext_lti_assignment_id = params[:ext_lti_assignment_id]
    custom_canvas_assignment_id = params[:custom_canvas_assignment_id]
    lms_instance_id = params[:lms_instance_id]
    @custom_canvas_lms_assignment_id =
      "#{lms_instance_id}-#{custom_canvas_assignment_id}"
    @lms_assignment_id = "#{lms_instance_id}-#{ext_lti_assignment_id}"

    if params[:from_collection].to_b
      workouts = Workout.where('lower(name) = ?',
        params[:workout_name].downcase)
      found_workout = workouts.andand.first
    end

    if session[:is_instructor].to_b
      workout_offerings = WorkoutOffering.where(
        lms_assignment_id: @lms_assignment_id)
      if workout_offerings.blank?
        workout_offerings = WorkoutOffering.where(
          lms_assignment_id: @custom_canvas_lms_assignment_id)
      end

      if workout_offerings.blank?
        # check current term
        workout_offerings = @user.managed_workout_offerings_in_term(
          params[:workout_name].downcase, @course, @term)
      end

      @workout_offering = workout_offerings.flatten.first

      if workout_offerings.blank?
        # check past terms
        workout_offerings = @user.managed_workout_offerings_in_term(
          params[:workout_name].downcase, @course, nil)
      end

      workout_offerings = workout_offerings.andand.flatten.uniq
      found_workout ||= workout_offerings.andand
        .uniq{ |wo| wo.workout }.andand
        .sort_by{ |wo| wo.course_offering.term.starts_on }.andand
        .last.andand.workout

      if !@workout_offering
        @course_offerings =
          @user.managed_course_offerings course: @course, term: @term
        if @course_offerings.blank?
          course_offering = CourseOffering.create(
            course: @course,
            term: @term,
            label: params[:label] ||
              "#{@user.label_name} - #{@term.display_name}",
            self_enrollment_allowed: true,
            lms_instance: LmsInstance.find(lms_instance_id)
          )

          @course_enrollment = CourseEnrollment.create(
            user: @user,
            course_offering: course_offering,
            course_role: CourseRole.instructor
          )

          @course_offerings << course_offering
        end
        if params[:from_collection].to_b && found_workout
          @course_offerings.each do |co|
            if co.lms_instance.nil?
              co.lms_instance_id = lms_instance_id
              co.save
            end

            @workout_offering = WorkoutOffering.new(
              course_offering: co,
              workout: found_workout,
              opening_date: DateTime.now,
              soft_deadline: nil,
              hard_deadline: nil,
              lms_assignment_id: @lms_assignment_id
            )
            @workout_offering.save
          end
        elsif found_workout
          redirect_to(organization_clone_workout_path(
            course_id: @course.slug,
            term_id: @term.slug,
            organization_id: @course.organization.slug,
            workout_id: found_workout.id,
            lti_launch: true,
            lms_assignment_id: @lms_assignment_id,
            suggested_name: params[:workout_name]
          )) and return
        else
          redirect_to organization_new_or_existing_workout_path(
              lti_launch: true,
              organization_id: @course.organization.slug,
              course_id: @course.slug,
              term_id: @term.slug,
              lms_assignment_id: @lms_assignment_id,
              suggested_name: params[:workout_name]
          ) and return
        end
      end
    else
      # first search by lms_assignment_id
      workout_offerings = WorkoutOffering.where(lms_assignment_id: @lms_assignment_id)
      if workout_offerings.blank?
        workout_offerings = WorkoutOffering.where(lms_assignment_id: @custom_canvas_lms_assignment_id)
      end
      if workout_offerings.blank?
        if params[:label] # label is specified, we can narrow down to a single course offering
          @course_offering = CourseOffering.find_by(course: @course, term: @term, label: params[:label])
          if @course_offering
            if params[:from_collection].to_b && found_workout
              workout_offerings = @course_offering.workout_offerings.where(workout: found_workout)
              @workout_offering = workout_offerings.first
            end
          else
            @message = 'Your course offering is not yet defined. Please contact your instructor.'
            render 'lti/error' and return
          end
        end
      else
        anchor_offering = workout_offerings.first
        sister_offerings = WorkoutOffering.joins(:course_offering)
          .where("(lms_assignment_id = '' OR lms_assignment_id is NULL)
                 AND course_id=#{anchor_offering.course_offering.course.id}
                 AND term_id=#{anchor_offering.course_offering.term.id}
                 AND workout_id=#{anchor_offering.workout.id}")
        workout_offerings = workout_offerings + sister_offerings
      end

      enrolled_course_offerings = @user.course_offerings_for_term(@term, @course)
      @course_offering ||= enrolled_course_offerings.first

      if workout_offerings.blank?
        # is the user enrolled in an offering of the course?

        if !@course_offering
          # let the user choose to enroll in a course_offering
          @available_offerings = []
          @available_course_offerings = CourseOffering.where(course: @course, term: @term)
            .select{ |co| co.self_enrollment_allowed? }
          render layout: 'one_column' and return
        else
          # have a course_offering, use the instructor to find appropriate workout_offerings
          # by workout name
          instructor = @course_offering.instructors.first
          workout_offerings = instructor
            .managed_workout_offerings_in_term(params[:workout_name].downcase, @course, @term)
          if workout_offerings.blank?
            # no current workout_offerings, check all semesters
            old_workout_offerings = instructor
              .managed_workout_offerings_in_term(params[:workout_name].downcase, @course, nil)
            found_workout ||= old_workout_offerings.andand
              .uniq{ |wo| wo.workout }.andand
              .sort_by{ |wo| wo.course_offering.term.starts_on }.andand
              .last.andand.workout
            if !found_workout
              @message = "The workout named #{params[:workout_name]} does not exist or is not linked with this LMS assignment. Please contact your instructor."
              render 'lti/error' and return
            else
              # we have a course offering and a workout -- just find or create the workout and redirect
              @workout_offering = WorkoutOffering.find_by(course_offering: @course_offering, workout: found_workout)
              if !@workout_offering
                @workout_offering = WorkoutOffering.new(
                  course_offering: @course_offering,
                  workout: found_workout,
                  opening_date: DateTime.now,
                  soft_deadline: nil,
                  hard_deadline: nil,
                  lms_assignment_id: @lms_assignment_id
                )
                @workout_offering.save
              end
            end
          end
        end
      end

      if !@workout_offering
        # don't have a workout_offering, but may have narrowed it down
        workout_offerings = workout_offerings.flatten.uniq
        enrolled_workout_offerings = workout_offerings.andand.select { |wo| @user.is_enrolled?(wo.course_offering) }

        if enrolled_workout_offerings.any?
          @workout_offering = enrolled_workout_offerings.andand.first
        elsif @course_offering
          # found an enrolled course_offering, so we don't need to ask the student anything
          # but the course offering does not include the workout offering, so add it
          workout_offering_options = {
            lms_assignment_id: @lms_assignment_id,
            from_collection: params[:from_collection]
          }
          @workout_offering = @course_offering.add_workout(params[:workout_name], workout_offering_options)
          if !@workout_offering
            @message = "The workout named '#{params[:workout_name]}' does not exist or is not linked with this LMS assignment. Please contact your instructor."
            render 'lti/error' and return
          end
        else
          # let the user choose to enroll in a course_offering
          @existing_workout_offerings = workout_offerings.uniq { |wo|
            wo.course_offering
          }.select { |wo|
            wo.course_offering.self_enrollment_allowed?
          }.map(&:id)
          @available_offerings = CourseOffering.where(course: @course, term: @term)
            .select{ |co| co.self_enrollment_allowed? }
          render layout: 'one_column' and return
        end
      end
    end

    # check enrollment and ties to LTI before proceeding
    role = session[:is_instructor].to_b ? CourseRole.instructor : CourseRole.student
    @course_offering = @workout_offering.course_offering

    if @course_offering.lms_instance.nil?
      @course_offering.lms_instance_id = lms_instance_id
      @course_offering.save
    end

    matching_lms_assignment_id = [@lms_assignment_id, @custom_canvas_lms_assignment_id].include?(@workout_offering.lms_assignment_id)

    should_reset_lms_assignment_id = !matching_lms_assignment_id && dynamic_lms_assignment

    if @workout_offering.lms_assignment_id.blank? || should_reset_lms_assignment_id
      @workout_offering.lms_assignment_id = @lms_assignment_id
      @workout_offering.save
    elsif !matching_lms_assignment_id
      raise RuntimeError, %(Expected lms-assignment-id to be "#{@lms_assignment_id}" or
        "#{@custom_canvas_lms_assignment_id}", but got "#{@workout_offering.lms_assignment_id}" instead.
        Some manual changing in the database may have occured without proper cleanup.)
    end

    if !@user.is_enrolled?(@course_offering) &&
        (@course_offering.can_enroll? || role.is_instructor?)
      CourseEnrollment.create(course_offering: @course_offering, user: @user, course_role: role)
    end

    # Reach here only if we have a @workout_offering
    redirect_to organization_workout_offering_practice_path(
      lis_outcome_service_url: params[:lis_outcome_service_url],
      lis_result_sourcedid: params[:lis_result_sourcedid],
      id: @workout_offering.id,
      organization_id: params[:organization_id],
      term_id: params[:term_id],
      course_id: params[:course_id],
      lti_launch: true
    )
  end


  # -------------------------------------------------------------
  def upload_yaml

  end


  # -------------------------------------------------------------
  def yaml_create
    @yaml_wkts = YAML.load_file(params[:form].fetch(:yamlfile).path)
    @yaml_wkts.each do |workout|
      wkt = workout['workout']
      @wkt = Workout.new
      @wkt.name = wkt['name']
      @wkt.scrambled = wkt['scrambled']
      @wkt.description = wkt['description']
      @wkt.save
      wkt['tags'].split(",").each do |t|
        Tag.tag_this_with(@wkt,t,Tag.skill)
      end
      wkt['exercises'].andand.each_with_index do |exer,i|
        if Exercise.find(exer['exid'][1..-1].to_i)
          ex_wkt = ExerciseWorkout.new
          ex_wkt.exercise_id = exer['exid'][1..-1].to_i
          ex_wkt.workout_id = @wkt.id
          ex_wkt.points = exer['points']
          ex_wkt.order = i + 1
          ex_wkt.save
        else
          puts "Exercise not found"
        end
      end
      wkt['offerings'].andand.each_with_index do |off, i|
        matching_course = Course.find_by(number: off['course']['number'],organization: Organization.find_by(abbreviation: off['course']['organization']['abbreviation']))
        if matching_course
          wkt_off = WorkoutOffering.new
          wkt_off.opening_date = off['opening_date']
          wkt_off.soft_deadline = off['soft_deadline']
          wkt_off.hard_deadline = off['hard_deadline']
          wkt_off.course_offering_id = matching_course.id
          wkt_off.workout_id = @wkt.id
          wkt_off.save
        else
          puts "No MATCHING COURSE","No MATCHING COURSE"
        end
      end
    end
    redirect_to workouts_path
  end


  # ------Placeholder for any views I want experiment with-------------------------------------------------------
  def dummy
    @workouts = Workout.find(1)
  end


  # -------------------------------------------------------------
  def evaluate
    if session[:current_workout].nil?
      redirect_to root_path, notice: 'Invalid action' and return
    end
    @workout_feedback = session[:workout_feedback].values
    @current_workout = Workout.find(session[:current_workout])
    @user_workout_score = WorkoutScore.find_by!(
      user_id: current_user.id, workout_id: session[:current_workout]).score
    @max_workout_score = @current_workout.returnTotalWorkoutPoints
    session[:current_workout] = nil
    session[:workout_feedback] = nil
    session[:wexes] = nil
    session[:remaining_wexes] = nil
    render layout: 'two_columns'
  end


  # -------------------------------------------------------------
  def update
    if cannot? :update, @workout
      redirect_to root_path,
        notice: 'Unauthorized to update workout' and return
    end
    
    workout_params = {
      name: params[:name],
      description: params[:description],
      is_public: params[:is_public],
      removed_exercises: params[:removed_exercises],
      exercises: params[:exercises]
    }

    if params[:course_id].blank?
      # no course, this workout needs to manage its own LTI ties
      workout_params[:lms_assignment_id] = params[:lms_assignment_id]
    end
    @workout = @workout.update_or_create(workout_params)

    if @workout && params[:course_id].present?
      workout_offering_id = create_or_update_offerings(@workout)
      if workout_offering_id
        url = url_for(organization_workout_offering_path(
            organization_id: params[:organization_id],
            term_id: params[:term_id],
            course_id: params[:course_id],
            id: workout_offering_id
          )
        )
      end
    elsif @workout
      url = url_for(workout_path(id: @workout.id))
    else
      url = url_for(root_path, notice: 'There was a problem updating the workout')
    end

    respond_to do |format|
      format.json { render json: { url: url } }
    end
  end


  # -------------------------------------------------------------
  # DELETE /workouts/1
  def destroy
    if cannot? :destroy, @workout
      redirect_to root_path,
        notice: 'Unauthorized to destroy workout' and return
    end
    @workout.destroy
    redirect_to workouts_url, notice: 'Workout was successfully destroyed.'
  end


  # -------------------------------------------------------------
  def practice
    @workout = Workout.find_by(id: params[:id])
    @lti_workout = LtiWorkout.find_by(id: params[:lti_workout_id])
    
    if !@lti_workout
      authorize! :practice, @workout
    end
    if @workout
      session[:current_workout] = @workout.id
      if current_user
        @workout_score = @workout.score_for(current_user, nil,
                                            params[:lis_outcome_service_url],
                                            params[:lis_result_sourcedid])
        if @workout_score.nil?
          # first time this workout is being accessed, create new
          @workout_score = WorkoutScore.new(
            score: 0,
            exercises_completed: 0,
            exercises_remaining: @workout.exercises.length,
            lis_result_sourcedid: params[:lis_result_sourcedid],
            lis_outcome_service_url: params[:lis_outcome_service_url],
            lti_workout: @lti_workout,
            user: current_user,
            workout: @workout)
          @workout_score.save!
        end
        current_user.current_workout_score = @workout_score
        current_user.save!
        if @workout_score.andand.closed? &&
          @workout_score.andand.workout_offering.andand.workout_policy.
          andand.no_review_before_close &&
          !@workout_score.andand.workout_offering.andand.shutdown?
          redirect_to workout_path(@workout),
            notice: "The time limit has passed for this workout." and return
        end
      end
      redirect_to exercise_practice_path(
        @workout.first_exercise, 
        workout_id: @workout.id, 
        lti_launch: params[:lti_launch],
        workout_score_id: @workout_score.andand.id
      )
    else
      redirect_to workouts, notice: 'Workout not found' and return
    end
  end


  #~ Private instance methods .................................................
  private

    # -------------------------------------------------------------
    # Use callbacks to share common setup or constraints between actions.
    def set_workout
      @workout = Workout.find(params[:id])
      @xp = 30
      @xptogo = 60
      @remain = 10
    end
  
    def create_or_update_offerings(workout)
      common = {}  # params that are common among all offerings of this workout
      common[:workout_policy] = WorkoutPolicy.find_by id: params[:policy_id]
      common[:time_limit] = params[:time_limit]
      common[:attempt_limit] = params[:attempt_limit]
      common[:published] = params[:published]
      common[:most_recent] = params[:most_recent]
      common[:lms_assignment_id] = params[:lms_assignment_id]

      removed_extensions = JSON.parse params[:removed_extensions]
      removed_extensions.each do |extension_id|
        StudentExtension.destroy extension_id
      end

      removed_offerings = JSON.parse params[:removed_offerings]
      removed_offerings.each do |workout_offering_id|
        workout.workout_offerings.destroy workout_offering_id
      end

      course_offerings = JSON.parse params[:course_offerings]
      workout_offerings =
        workout.add_workout_offerings(course_offerings, common)
      workout.save!
      return workout_offerings.first
    end

    # -------------------------------------------------------------
    # Only allow a trusted parameter "white list" through.
    def workout_params
      params.require(:workout).permit(
        :description,
        :exercise_ids,
        :exercise_workout,
        :exercise_workouts_attributes,
        :hard_deadline,
        :name,
        :opening_date,
        :points_multiplier,
        :scrambled,
        :soft_deadline,
        :target_group,
        :workout_offerings_attributes
      )
    end

end
