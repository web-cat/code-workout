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
        render plain:
          WorkoutRepresenter.for_collection.new(@workouts).to_hash.to_json
      end
      format.yml do
        render plain:
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
  # The export function gets all workouts metadata for SPLICE
  # GET /gym/workouts/export
  def export
    workouts = Workout.where(is_public: true)

    catalog = workouts.map do |workout|
      item = {
        catalog_type: "SLCItem",
        persistentID: workout.external_id.to_s,
        platform_name: "CodeWorkout",
        iframe_url: practice_workout_url(workout) + "?lti_launch=true",
        title: workout.name.to_s,
        description: workout.description,
        author: workout.owners.empty? ? [workout.creator&.display_name_with_email].compact : workout.owners.map(&:display_name_with_email),
        features: (["Workout", "Problem Set"] + workout.exercises.flat_map { |ex| ex.styles.map(&:name) }).uniq,
        institution: ["Virginia Tech"],
        keywords: (workout.tags.map(&:name) +
          workout.exercises.flat_map { |ex| ex.tags.map(&:name) + ex.styles.map(&:name) }).uniq,
        programming_language: workout.exercises.flat_map { |ex| ex.languages.map(&:name) }.uniq,
        natural_language: ["English"],
        protocols: ['LTI'],
        protocol_urls: [lti_launch_url + "?gym_workout_id=" + workout.id.to_s]
      }
    end

    render json: catalog
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
    @exs = @workout.exercises.includes(:languages, :tags, :current_version)
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
    @gym = Workout.includes(:tags, :exercise_workouts, :workout_scores, exercises: :irt_data).
      where(is_public: true).order('created_at DESC').limit(12)
    # render layout: 'two_columns'
  end


  # -------------------------------------------------------------
  # GET /workouts/new
  def new
    @lti_launch = params[:lti_launch]
    @workout = Workout.new

    @message = 'Unauthorized to create new workout'

    if params[:course_id]
      # Working with workout_offerings; gather info to populate form
      @term = params[:term_id] ? Term.find(params[:term_id]) : nil
      @organization = params[:organization_id] ?
        Organization.find(params[:organization_id]) : nil
      @course = Course.find_with_id_or_slug(params[:course_id], params[:organization_id])
      @course_offerings = current_user.managed_course_offerings(
        course: @course, term: @term)
      @return_to = organization_course_path(
        organization_id: @organization.slug,
        id: @course.slug,
        term_id: @term.slug
      )
    end

    # Only let the user through if
    # they're an admin OR
    # there's a course involved AND they have course level permissions
    unless current_user.global_role.is_admin? ||
      (@course && current_user.can?(:new, Workout))
      redirect_to root_path, notice: @message and return
    end

    @lms_assignment_id = params[:lms_assignment_id]
    @lms_instance_id = params[:lms_instance_id]
    @suggested_name = params[:suggested_name]
    @policy = WorkoutPolicy.new

    if params[:notice]
      flash.now[:notice] = params[:notice]
    end

    render layout: 'two_columns'
  end

  # /gym/workouts/new_or_existing
  # /courses/:organization_id/:course_id/:term_id/workouts/new_or_existing
  def new_or_existing
    @lti_launch = params[:lti_launch]

    if params[:course_id]
      @course = Course.find_with_id_or_slug(
        params[:course_id],
        params[:organization_id]
      )
    end

    # If there is a course, check course roles (in the ability file)
    # If there is no course, check LTI launch roles
    @can_create = (@course && can?(:new, Workout)) || session[:is_instructor]

    unless @can_create
      flash.now[:notice] =
        'You are unauthorized to create new workouts. Choose from existing workouts instead.'
    end

    @term = !!params[:term_id] ? Term.find(params[:term_id]) : nil
    @organization = !!params[:organization_id] ?
      Organization.find(params[:organization_id]) : nil
    @suggested_name = params[:suggested_name]

    @lms_assignment_id = params[:lms_assignment_id]
    @lti_assignment_id = params[:lti_assignment_id]

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
        lti_assignment_id: @lti_assignment_id,
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
      @course = Course.find_with_id_or_slug(
        params[:course_id],
        params[:organization_id]
      )
      @term = Term.find(params[:term_id])
      @organization = Organization.find params[:organization_id]
      @time_limit = @workout_offering.andand.time_limit
      @attempt_limit = @workout_offering.andand.attempt_limit
      @published = @workout_offering.andand.published
      @most_recent = @workout_offering.andand.most_recent
      @policy = @workout_offering.andand.workout_policy || @workout.workout_policy || WorkoutPolicy.new

      @workout_offerings = current_user.managed_workout_offerings_in_term(
        @workout, @course, @term).to_a.flatten

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

      @return_to = organization_workout_offering_path(
        @workout_offering,
        organization_id: @organization,
        course_id: @course,
        term_id: @term,
      )
      @date_yaml = serialize_workout_offerings_to_yaml(@workout_offerings, @student_extensions)
    else
      @policy = @workout.workout_policy || WorkoutPolicy.new
      @date_yaml = serialize_workout_offerings_to_yaml([], [])
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
    @lti_assignment_id = params[:lti_assignment_id]

    authorize! :clone, @workout, message: message

    if params[:lms_instance_id].present?
      lti_workout = LtiWorkout.create(
        lms_assignment_id: @lti_assignment_id || @lms_assignment_id,
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
    @policy = (@workout.workout_policy || WorkoutPolicy.new).dup
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
      @course = Course.find_with_id_or_slug(
        params[:course_id],
        params[:organization_id]
      )
      @term = Term.find params[:term_id]
      @can_update = can? :edit, @workout
      @workout_offering = @workout.workout_offerings.first
      @time_limit = @workout_offering.andand.time_limit
      @attempt_limit = @workout_offering.andand.attempt_limit
      @policy = (@workout_offering.andand.workout_policy || @policy).dup
      @organization = Organization.find params[:organization_id]
      @course_offerings =
        current_user.andand.managed_course_offerings(course: @course, term: @term)
      @unused_course_offerings = nil
    end

    @return_to = organization_course_path(
      organization_id: @organization.slug,
      id: @course.slug,
      term_id: @term.slug
    )

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
      workout_params[:lti_assignment_id] = params[:lti_assignment_id]
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


  # /courses/:organization_id/:course_id/:term_id/find_offering/:workout_name
  def find_offering
    @user = User.find params[:user_id]
    @term = Term.find params[:term_id]
    @course = Course.find_with_id_or_slug(params[:course_id], params[:organization_id])
    @lti_launch = params[:lti_launch]
    dynamic_lms_assignment = params[:dynamic_lms_assignment].to_b
    ext_lti_assignment_id = params[:ext_lti_assignment_id]
    custom_canvas_assignment_id = params[:custom_canvas_assignment_id]
    
    # Restore from session if not present in params
    payload = session[:lti_payload] || {}
    lms_instance_id = params[:lms_instance_id] || payload['lms_instance_id']
    lti_context_id = params[:lti_context_id] || payload['lti_context_id']
    canvas_course_id = params[:canvas_course_id] || payload['canvas_course_id']
    custom_section_ids = params[:custom_section_ids] || payload['custom_section_ids']
    custom_section_names = params[:custom_section_names] || payload['custom_section_names']
    context_label = params[:context_label] || payload['context_label']
    context_title = params[:context_title] || payload['context_title']
    
    resource_link_id = params[:resource_link_id]
    lms_section_ids = custom_section_ids.to_s.split(',')
    
    @custom_canvas_lms_assignment_id = custom_canvas_assignment_id
    @lms_assignment_id = ext_lti_assignment_id
    
    role = session[:is_instructor].to_b ? CourseRole.instructor : CourseRole.student

    session[:lti_payload] = {
      lms_instance_id: lms_instance_id,
      lti_context_id: lti_context_id,
      canvas_course_id: canvas_course_id,
      custom_section_ids: custom_section_ids,
      custom_section_names: custom_section_names,
      context_label: context_label,
      context_title: context_title
    }

    # Phase 1: CourseOffering Resolution
    candidate_course_offerings = []

    if params[:course_offering_id].present?
      candidate_course_offerings = [CourseOffering.find(params[:course_offering_id])]
    else
      if lms_instance_id.present? && lti_context_id.present?
        query = { lms_instance_id: lms_instance_id, lti_context_id: lti_context_id }
        query[:lms_section_id] = lms_section_ids if lms_section_ids.any?
        candidate_course_offerings = CourseOffering.where(query).to_a
      end

      if candidate_course_offerings.empty? && lms_instance_id.present? && canvas_course_id.present?
        query = { lms_instance_id: lms_instance_id, canvas_course_id: canvas_course_id }
        query[:lms_section_id] = lms_section_ids if lms_section_ids.any?
        candidate_course_offerings = CourseOffering.where(query).to_a
      end
    end

    if candidate_course_offerings.empty?
      if role.is_instructor?
        candidate_course_offerings = @user.managed_course_offerings(course: @course, term: @term).to_a
      else
        candidate_course_offerings = @user.course_offerings_for_term(@term, @course).to_a
      end
    end

    @course_offering = nil
    if role.is_instructor?
      if candidate_course_offerings.count == 1
        @course_offering = candidate_course_offerings.first
      elsif candidate_course_offerings.count > 1
        session[:candidate_course_offering_ids] = candidate_course_offerings.map(&:id)
        redirect_to organization_course_select_offering_path(
          organization_id: @course.organization.slug,
          course_id: @course.slug,
          term_id: @term.slug,
          workout_name: params[:workout_name],
          ext_lti_assignment_id: ext_lti_assignment_id,
          custom_canvas_assignment_id: custom_canvas_assignment_id,
          resource_link_id: resource_link_id,
          from_collection: params[:from_collection]
        ) and return
      else
        redirect_to new_organization_course_offering_path(
          organization_id: @course.organization.slug,
          course_id: @course.slug,
          term_id: @term.slug,
          workout_name: params[:workout_name],
          ext_lti_assignment_id: ext_lti_assignment_id,
          custom_canvas_assignment_id: custom_canvas_assignment_id,
          resource_link_id: resource_link_id,
          from_collection: params[:from_collection]
        ) and return
      end
    else
      if candidate_course_offerings.any?
        if lms_section_ids.any? && candidate_course_offerings.any? { |co| lms_section_ids.include?(co.lms_section_id) }
          first_matching_id = lms_section_ids.find { |id| candidate_course_offerings.any? { |co| co.lms_section_id == id } }
          @course_offering = candidate_course_offerings.find { |co| co.lms_section_id == first_matching_id }
        else
          @course_offering = candidate_course_offerings.first
        end
      else
        @message = "Your course offering is not yet available. Please contact your instructor."
        render 'lti/error' and return
      end
    end

    # Phase 2: WorkoutOffering Resolution
    @workout_offering = nil
    
    if resource_link_id.present?
      @workout_offering = WorkoutOffering.find_by(lms_instance_id: lms_instance_id, resource_link_id: resource_link_id)
    end
    if !@workout_offering && @lms_assignment_id.present?
      @workout_offering = WorkoutOffering.find_by(lms_instance_id: lms_instance_id, lti_assignment_id: @lms_assignment_id)
    end
    if !@workout_offering && @custom_canvas_lms_assignment_id.present?
      @workout_offering = WorkoutOffering.find_by(lms_instance_id: lms_instance_id, lms_assignment_id: @custom_canvas_lms_assignment_id)
    end

    found_workout = nil
    if params[:from_collection].to_b
      workouts = Workout.where('lower(name) = ?', params[:workout_name].downcase)
      found_workout = workouts.first
    end

    if !@workout_offering
      if found_workout
        @workout_offering = @course_offering.workout_offerings.find_by(workout_id: found_workout.id)
      else
        @workout_offering = @course_offering.workout_offerings.joins(:workout).find_by('lower(workouts.name) = ?', params[:workout_name].downcase)
      end
    end

    # Phase 3: WorkoutOffering Fallback / Creation
    if !@workout_offering
      if role.is_instructor?
        if !found_workout
           old_workout_offerings = @user.managed_workout_offerings_in_term(params[:workout_name].downcase, @course, nil).to_a.flatten
           found_workout = old_workout_offerings.uniq{ |wo| wo.workout }.sort_by{ |wo| wo.course_offering.term.starts_on }.last.andand.workout
        end
        
        if params[:from_collection].to_b && found_workout
          @workout_offering = WorkoutOffering.create(
            course_offering: @course_offering,
            workout: found_workout,
            opening_date: DateTime.now,
            lms_assignment_id: @custom_canvas_lms_assignment_id,
            lti_assignment_id: @lms_assignment_id,
            resource_link_id: resource_link_id,
            lms_instance_id: lms_instance_id
          )
        elsif found_workout
          redirect_to(organization_clone_workout_path(
            course_id: @course.slug,
            term_id: @term.slug,
            organization_id: @course.organization.slug,
            workout_id: found_workout.id,
            lti_launch: true,
            lms_assignment_id: @lms_assignment_id,
            lti_assignment_id: @lms_assignment_id,
            suggested_name: params[:workout_name]
          )) and return
        else
          redirect_to organization_new_or_existing_workout_path(
              lti_launch: true,
              organization_id: @course.organization.slug,
              course_id: @course.slug,
              term_id: @term.slug,
              lms_assignment_id: @lms_assignment_id,
              lti_assignment_id: @lms_assignment_id,
              suggested_name: params[:workout_name]
          ) and return
        end
      else
        @message = "The workout named '#{params[:workout_name]}' does not exist or is not linked with this LMS assignment. Please contact your instructor."
        render 'lti/error' and return
      end
    end

    # Phase 4: Validation / Backfill
    if @course_offering.lms_instance_id.blank?
      @course_offering.lms_instance_id = lms_instance_id
    end
    if @course_offering.lti_context_id.blank?
      @course_offering.lti_context_id = lti_context_id
    end
    if @course_offering.lms_section_id.blank? && lms_section_ids.length == 1
      @course_offering.lms_section_id = lms_section_ids.first
    end
    if @course_offering.canvas_course_id.blank?
      @course_offering.canvas_course_id = canvas_course_id
    end
    if @course_offering.changed?
      @course_offering.save
    end

    if @workout_offering.resource_link_id.blank?
      @workout_offering.resource_link_id = resource_link_id
    end
    if @workout_offering.lti_assignment_id.blank? || (dynamic_lms_assignment && @workout_offering.lti_assignment_id != @lms_assignment_id)
      @workout_offering.lti_assignment_id = @lms_assignment_id
    end
    if @workout_offering.lms_assignment_id.blank? || (dynamic_lms_assignment && @workout_offering.lms_assignment_id != @custom_canvas_lms_assignment_id)
      @workout_offering.lms_assignment_id = @custom_canvas_lms_assignment_id
    end
    if @workout_offering.lms_instance_id.blank?
      @workout_offering.lms_instance_id = lms_instance_id
    end
    if @workout_offering.changed?
      @workout_offering.save
    end

    if !@user.is_enrolled?(@course_offering)
      CourseEnrollment.create(course_offering: @course_offering, user: @user, course_role: role)
    end

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
    @yaml_wkts = YAML.safe_load(File.read(params[:form].fetch(:yamlfile).path))
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
    @workout_feedback = session[:workout_feedback].andand.values || []
    @current_workout = Workout.find(params[:id])
    @user_workout_score = WorkoutScore.find_by!(
      user_id: current_user.id, workout_id: @current_workout.id).score
    @max_workout_score = @current_workout.returnTotalWorkoutPoints
    session[:workout_feedback] = nil
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
    token = params[:lti_launch]
    if lti_context_for_token(token)
      @lti_launch = token
    else
      @lti_launch = nil
    end

    if @workout
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
        manages_course = current_user.andand.global_role.andand.is_admin? ||
          @workout_score.andand.workout_offering.andand.course_offering.andand.is_manager?(current_user)
        policy = @workout_score.andand.workout_offering.andand.workout_policy
        if !manages_course && @workout_score.andand.closed? &&
          (policy.andand.see_answers == false ||
           (policy.andand.no_review_before_close && !@workout_score.andand.workout_offering.andand.shutdown?))
          redirect_to workout_path(@workout),
            notice: "The time limit has passed for this workout." and return
        end
      end
      redirect_to exercise_practice_path(
        @workout.first_exercise,
        workout_id: @workout.id,
        lti_launch: @lti_launch,
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
      @workout = Workout.includes(:tags, :exercise_workouts, :workout_offerings).find(params[:id])
      @xp = 30
      @xptogo = 60
      @remain = 10
    end

    def create_or_update_offerings(workout)
      common = {}  # params that are common among all offerings of this workout
      policy_params = params[:policy].present? ? JSON.parse(params[:policy]) : {}
      
      policy = workout.workout_policy || WorkoutPolicy.create!
      policy.update(policy_params)

      # Ensure all existing offerings use this policy
      workout.workout_offerings.update_all(workout_policy_id: policy.id)
      common[:workout_policy] = policy
      common[:time_limit] = params[:time_limit]
      common[:attempt_limit] = params[:attempt_limit]
      common[:published] = params[:published]
      common[:most_recent] = params[:most_recent]
      common[:lms_assignment_id] = params[:lms_assignment_id]
      common[:lti_assignment_id] = params[:lti_assignment_id]

      if params[:date_yaml].present?
        begin
          data = YAML.safe_load(params[:date_yaml])
          sections_yaml = data['sections'] || []
          extensions_yaml = data['extensions'] || []
          
          user_tz = current_user.time_zone.andand.name || 'America/New_York'
          @course = Course.find_with_id_or_slug(params[:course_id], params[:organization_id])
          @term = Term.find(params[:term_id])
          
          managed_course_offerings = current_user.managed_course_offerings(course: @course, term: @term)
          managed_course_offerings_map = managed_course_offerings.each_with_object({}) { |co, h| h[co.label] = co }
          
          # 1. Handle Workout Offerings
          new_offerings_data = {}
          sections_yaml.each do |s|
            label = s['section']
            co = managed_course_offerings_map[label]
            if co
              due = parse_date(s['due'], user_tz)
              from = parse_date(s['from'], user_tz, due, :from)
              until_date = parse_date(s['until'], user_tz, due, :until)
              
              new_offerings_data[co.id.to_s] = {
                'opening_date' => from.andand.to_i.andand.*(1000), # millisecond timestamp for add_workout_offerings
                'soft_deadline' => due.andand.to_i.andand.*(1000),
                'hard_deadline' => until_date.andand.to_i.andand.*(1000),
                'extensions' => []
              }
            else
              workout.errors.add(:base, "Course offering with label '#{label}' not found or not managed by you.")
            end
          end
          
          # Identify removed offerings
          existing_offerings = workout.workout_offerings.joins(:course_offering).where(course_offerings: { term_id: @term.id })
          existing_offering_ids = existing_offerings.map(&:id)
          kept_offering_co_ids = new_offerings_data.keys.map(&:to_i)
          
          offerings_to_delete = existing_offerings.reject { |wo| kept_offering_co_ids.include?(wo.course_offering_id) }
          offerings_to_delete.each(&:destroy)
          
          # Update/Create Offerings
          workout_offerings = workout.add_workout_offerings(new_offerings_data, common)
          
          # 2. Handle Student Extensions
          # First, clear existing extensions for this workout in this term
          # (Easier to rebuild than to diff grouped YAML)
          workout_offerings_in_term = workout.workout_offerings.joins(:course_offering).where(course_offerings: { term_id: @term.id })
          StudentExtension.where(workout_offering_id: workout_offerings_in_term.map(&:id)).destroy_all
          
          extensions_yaml.each do |ext_group|
              due = parse_date(ext_group['due'], user_tz)
              from = parse_date(ext_group['from'], user_tz, due, :from)
              until_date = parse_date(ext_group['until'], user_tz, due, :until)
            students = ext_group['students'] || []
            
            students.each do |student_ref|
              next if student_ref == '<insert email here>'
              
              # Extract email from "Name <email>" or just "email"
              email = student_ref.match(/<([^>]+)>/).andand[1] || student_ref.strip
              student = User.find_by(email: email)
              if !student
                # Try name match
                student = User.where("CONCAT(first_name, ' ', last_name) = ?", student_ref.strip).first
              end
              
              if student
                # Check enrollment in any of the workout offerings in this term
                enrolled_offering = workout_offerings_in_term.find { |wo| wo.course_offering.is_enrolled?(student) }
                if enrolled_offering
                  StudentExtension.create!(
                    user: student,
                    workout_offering: enrolled_offering,
                    opening_date: from,
                    soft_deadline: due,
                    hard_deadline: until_date
                  )
                else
                  workout.errors.add(:base, "Student '#{student_ref}' is not enrolled in any sections for this workout.")
                end
              else
                workout.errors.add(:base, "Student '#{student_ref}' not found by email or name.")
              end
            end
          end
          
          workout.save!
          return workout_offerings.first
          
        rescue Psych::SyntaxError => e
          workout.errors.add(:base, "YAML Syntax Error: #{e.message}")
          return nil
        rescue StandardError => e
          workout.errors.add(:base, "Error processing YAML: #{e.message}")
          return nil
        end
      else
        # Fallback to legacy JSON behavior if date_yaml is not present
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
    end

    def search_students
      @course = Course.find_with_id_or_slug(params[:course_id], params[:organization_id])
      @term = Term.find(params[:term_id])
      term = escape_javascript(params[:term]).downcase
      
      # Get all students enrolled in any course offering for this course in this term
      course_offerings = CourseOffering.where(course: @course, term: @term)
      users = User.joins(:course_enrollments)
                  .where(course_enrollments: { course_offering_id: course_offerings.map(&:id) })
                  .where("lower(first_name) like ? or lower(last_name) like ? or lower(email) like ?", "%#{term}%", "%#{term}%", "%#{term}%")
                  .distinct
      
      render json: users.map { |u| { 
        id: u.id, 
        first_name: u.first_name, 
        last_name: u.last_name, 
        email: u.email 
      } }
    end

    # -------------------------------------------------------------
    def serialize_workout_offerings_to_yaml(workout_offerings, student_extensions)
      user_tz = current_user.time_zone.andand.name || 'America/New_York'
      
      sections = workout_offerings.map do |wo|
        {
          'section' => wo.course_offering.display_name_with_term,
          'due' => format_date(wo.soft_deadline, user_tz),
          'from' => format_rel_date(wo.opening_date, wo.soft_deadline, user_tz) || 'always',
          'until' => format_rel_date(wo.hard_deadline, wo.soft_deadline, user_tz) || '+0 minutes'
        }
      end

      # Group extensions by dates
      grouped_extensions = {}
      student_extensions.each do |ext|
        key = {
          'due' => format_date(ext.soft_deadline, user_tz),
          'from' => format_rel_date(ext.opening_date, ext.soft_deadline, user_tz) || 'always',
          'until' => format_rel_date(ext.hard_deadline, ext.soft_deadline, user_tz) || '+0 minutes'
        }
        
        grouped_extensions[key] ||= []
        grouped_extensions[key] << "#{ext.user.display_name} <#{ext.user.email}>"
      end

      ext_list = grouped_extensions.map do |dates, students|
        {
          'due' => dates['due'],
          'from' => dates['from'],
          'until' => dates['until'],
          'students' => students
        }
      end

      if ext_list.empty?
        ext_list << {
          'due' => '',
          'from' => 'always',
          'until' => '+0 minutes',
          'students' => ['<insert email here>']
        }
      end

      yaml_obj = {
        'sections' => sections,
        'extensions' => ext_list
      }
      
      # Use custom formatting to avoid unnecessary quotes and handle nulls as requested
      yaml_str = yaml_obj.to_yaml
      yaml_str.gsub!(/^---\n/, '')
      # Remove quotes from keys
      yaml_str.gsub!(/^(\s*)['"]([^'"]+)['"]:/, '\1\2:')
      # Remove quotes from values where possible (simple dates and names)
      yaml_str.gsub!(/: ['"]([^'"]*)['"]$/, ': \1')
      # Remove quotes from list items (like student names/emails)
      yaml_str.gsub!(/^(\s*)- ['"]([^'"]*)['"]$/, '\1- \2')
      # Handle empty strings as requested (no quotes)
      yaml_str.gsub!(/: (''|"")$/, ': ')
      yaml_str
    end

    def format_rel_date(target, relative_to, tz)
      return nil if target.nil? || relative_to.nil?
      diff = (target.to_time.to_f - relative_to.to_time.to_f).round(0)
      sign = diff >= 0 ? '+' : '-'
      abs_diff = diff.abs
      
      # (1) Exact integral number of days
      if abs_diff % 86400 == 0
        val = abs_diff / 86400
        return "#{sign}#{val} #{val == 1 ? 'day' : 'days'}"
      end
      
      # (2) Less than 24 hours and exact integral number of hours
      if abs_diff < 86400 && abs_diff % 3600 == 0
        val = abs_diff / 3600
        return "#{sign}#{val} #{val == 1 ? 'hour' : 'hours'}"
      end
      
      # (3) Less than 181 minutes and exact integral number of minutes
      if abs_diff < (181 * 60) && abs_diff % 60 == 0
        val = abs_diff / 60
        return "#{sign}#{val} #{val == 1 ? 'minute' : 'minutes'}"
      end
      
      # (4) Otherwise, render as absolute date/time
      format_date(target, tz)
    end

    def format_date(date, tz)
      return '' if date.nil? || (date.is_a?(Numeric) && date == 0)
      d = date.is_a?(Numeric) ? Time.at(date) : date
      d.in_time_zone(tz).strftime('%Y-%m-%d %I:%M %p')
    end

    def parse_date(date_str, tz, relative_to = nil, mode = nil)
      return nil if date_str.blank?
      
      val = date_str.to_s.strip.downcase
      return nil if ['null', 'nil', 'empty'].include?(val)
      if mode == :from && ['always', 'unlimited'].include?(val)
        return nil
      end
      
      # Check for relative offset: +N days, -N hours, or just N days
      # Flexible regex: optional sign, float/int, flexible whitespace, abbreviated units
      if relative_to && date_str.strip.match?(/^([+-]?)\s*(\d*\.?\d+)\s*([a-z]+)$/i)
        match = date_str.strip.match(/^([+-]?)\s*(\d*\.?\d+)\s*([a-z]+)$/i)
        sign = match[1]
        amount = match[2].to_f
        unit_str = match[3].downcase
        
        # Unit mapping
        unit_map = {
          'm' => 'minute', 'min' => 'minute', 'mins' => 'minute', 'minutes' => 'minute',
          'h' => 'hour', 'hr' => 'hour', 'hrs' => 'hour', 'hour' => 'hour', 'hours' => 'hour',
          'd' => 'day', 'day' => 'day', 'days' => 'day',
          'w' => 'week', 'wk' => 'week', 'wks' => 'week', 'week' => 'week', 'weeks' => 'week'
        }
        
        unit = unit_map[unit_str]
        raise StandardError, "Unknown unit '#{unit_str}'" unless unit
        
        # Validate and determine operator based on mode and sign
        if mode == :from
          if sign == '+'
            raise StandardError, "Relative values for 'from' (opening date) must be negative. Use '-' or no sign."
          end
          operator = '-'
        elsif mode == :until
          if sign == '-'
            raise StandardError, "Relative values for 'until' (hard deadline) must be non-negative. Use '+' or no sign."
          end
          operator = '+'
        else
          operator = sign.blank? ? '+' : sign
        end
        
        # Calculate offset
        duration = amount.send(unit)
        if operator == '+'
          return relative_to + duration
        else
          return relative_to - duration
        end
      end
      
      # Absolute date
      begin
        # Use Time.zone.parse which respects the current zone if set, 
        # but here we want to use the user's zone.
        Time.use_zone(tz) do
          Time.zone.parse(date_str)
        end
      rescue
        nil
      end
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
        :workout_offerings_attributes,
        :date_yaml
      )
    end

end
