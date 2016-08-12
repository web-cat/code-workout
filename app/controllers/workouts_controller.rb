require 'json'
require 'date'

class WorkoutsController < ApplicationController
  before_action :set_workout, only: [:show, :edit, :update, :destroy]
  after_action :allow_iframe, only: [:new, :new_create, :edit]
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
  # GET /workouts/1
  def show
    @exs = @workout.exercises
  end

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
    if cannot? :new, Workout
      redirect_to root_path,
        notice: 'Unauthorized to create new workout' and return
    end
    @lti_launch = params[:lti_launch]
    @workout = Workout.new
    if params[:notice]
      flash.now[:notice] = params[:notice]
    end

    if @lti_launch
      render layout: 'one_column'
    else
      render layout: 'two_columns'
    end
  end

  # -------------------------------------------------------------
  # GET /gym/workouts/existing_or_new
  def new_or_existing
    if cannot? :new, Workout
      flash.now[:notice] = 'You are unauthorized to create new workouts. Choose from existing workouts instead.'
    end

    @lti_launch = params[:lti_launch]

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
    @terms = escape_javascript(params[:search])
    @terms = @terms.split(@terms.include?(' ') ? /\s*,\s*/ : nil)
    @workouts = Workout.search @terms, current_user

    if @workouts.blank?
      @msg = 'Your search did not match any workouts. Try these instead...'
      @workouts = Workout.visible_to_user(current_user).shuffle.first(16)
    end

    if @workouts.blank?
      @msg = 'No public workouts exist yet. Please wait for contributors to add more.'
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  # -------------------------------------------------------------
  # GET /workouts/1/edit
  def edit
    if cannot? :edit, @workout
      redirect_to root_path, notice: 'Unauthorized to edit workout' and return
    end
    @can_update = false
    @workout.workout_offerings.each do |wo|
      wo.course_offering.course_enrollments.each do |e|
        if e.user_id == current_user.id && e.course_role.can_manage_assignments
          @can_update = true
        end
      end
    end

    if @workout.creator_id == current_user.id
      @can_update = true
    end

    @lti_launch = params[:lti_launch]
    @exs = []
    @workout.exercises.each do |exer|
      @exs << exer.id
    end

    @exercises = []
    @workout.exercise_workouts.each do |ex|
      ex_data = {}
      ex_data[:name] = ex.exercise.name
      ex_data[:points] = ex.points
      ex_data[:id] = ex.exercise_id
      ex_data[:exercise_workout_id] = ex.id
      @exercises.push(ex_data)
    end

    if @lti_launch
      render layout: 'one_column'
    else
      render layout: 'two_columns'
    end
  end

  def create
    @workout = Workout.new
    @workout.creator_id = current_user.id
    create_or_update

    if @workout.save
      if lti_params = session[:lti_params]
        url = url_for(course_offerings_path(lti_launch: true))
      else
        url = url_for root_path(notice: 'Workout was successfully created.')
      end
    else
      err_string = 'There was a problem while creating the workout.'
      url = url_for new_workout_path(notice: err_string)
    end

    respond_to do |format|
      format.json { render json: { url: url } }
    end
  end

  def upload_yaml

  end

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
  # PATCH/PUT /workouts/1
  # def update
  #   if cannot? :update, @workout
  #     redirect_to root_path,
  #       notice: 'Unauthorized to update workout' and return
  #   end
  #   if @workout.update(workout_params)
  #     redirect_to @workout, notice: 'Workout was successfully updated.'
  #   else
  #     render action: 'edit'
  #   end
  # end

  def update
    if cannot? :update, @workout
      redirect_to root_path,
        notice: 'Unauthorized to update workout' and return
    end

    create_or_update
    @workout.save!
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
    authorize! :practice, @workout
    if @workout
      if !user_signed_in?
        redirect_to workout_path(@workout),
          notice: "Need to Sign in to practice" and return
      end
      session[:current_workout] = @workout.id
      if current_user
        @workout_score = @workout.score_for(current_user)
        if @workout_score.nil?
          @workout_score = WorkoutScore.new(
            score: 0,
            exercises_completed: 0,
            exercises_remaining: @workout.exercises.length,
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
      ex1 = @workout.next_exercise(nil, current_user, @workout_score)
      redirect_to exercise_practice_path(id: ex1.id, workout_id: @workout.id)
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

    def create_or_update
      @workout.name = params[:name]
      @workout.description = params[:description]
      @workout.is_public = true
      workout_policy = WorkoutPolicy.find_by id: params[:policy_id]
      time_limit = params[:time_limit]
      removed_exercises = params[:removed_exercises].split ','
      removed_exercises.each do |exercise_workout_id|
        @workout.exercise_workouts.destroy exercise_workout_id
      end
      exercises = JSON.parse params[:exercises]
      exercises.each do |key, value|
        exercise = Exercise.find value['id']
        exercise_workout = ExerciseWorkout.find_by workout: @workout, exercise: exercise
        if exercise_workout.blank?
          exercise_workout = ExerciseWorkout.new workout: @workout, exercise: exercise
        end
        exercise_workout.position = key
        exercise_workout.points = value['points']
        exercise_workout.save!
      end

      course_offerings = JSON.parse params[:course_offerings]
      parse_course_offerings(course_offerings, time_limit, workout_policy)
    end

    # Parses course offerings from json and adds them
    # to the workout
    def parse_course_offerings(course_offerings, time_limit, workout_policy)
      if @workout
        course_offerings.each do |id, offering|
          course_offering = CourseOffering.find(id)
          @workout_offering = WorkoutOffering.find_by(workout: @workout, course_offering: course_offering)
          if @workout_offering.blank?
            @workout_offering = WorkoutOffering.new
          end
          @workout_offering.workout = @workout
          @workout_offering.course_offering = course_offering
          @workout_offering.time_limit = time_limit
          @workout_offering.opening_date = DateTime.parse(offering['opening_date']) if offering['opening_date']
          @workout_offering.soft_deadline = DateTime.parse(offering['soft_deadline']) if offering['soft_deadline']
          @workout_offering.hard_deadline = DateTime.parse(offering['hard_deadline']) if offering['hard_deadline']
          @workout_offering.workout_policy = workout_policy
          @workout_offering.save!

          extensions = offering['extensions']
          extensions.each do |ext|
            students = ext['students']
            students.each do |student_id|
              student = User.find(student_id)
              student_extension = StudentExtension.new
              student_extenion.user = student
              student_extenion.workout_offering = @workout_offering
              student_extenion.opening_date = DateTime.parse(ext['opening_date']) if ext['opening_date']
              student_extenion.soft_deadline = DateTime.parse(ext['soft_deadline']) if ext['soft_deadline']
              student_extenion.hard_deadline = DateTime.parse(ext['hard_deadline']) if ext['hard_deadline']
              student_extenion.time_limit = ext['time_limit']
              student_extension.save!
            end
          end
        end
      end
    end

    # -------------------------------------------------------------
    # Only allow a trusted parameter "white list" through.
    def workout_params
      params.require(:workout).permit(:name, :scrambled, :exercise_ids,
        :description, :target_group, :points_multiplier, :opening_date, :exercise_workout,
        :exercise_workouts_attributes, :workout_offerings_attributes,
        :soft_deadline, :hard_deadline)
    end

end
