class WorkoutsController < ApplicationController 
  before_action :set_workout, only: [:show, :edit, :update, :destroy]
  respond_to :html, :js

  #~ Action methods ...........................................................

  # -------------------------------------------------------------
  # GET /workouts
  def index
    if cannot? :index, Workout
      redirect_to root_path,
        notice: 'Unauthorized to view all workouts' and return
    end
    @workouts = Workout.all
    @gym = Workout.order("created_at DESC").limit(12)
    #render layout: 'two_columns'
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


  # -------------------------------------------------------------
  # GET /gym
  def gym
    @gym = Workout.where(target_group: 'Public').order('created_at DESC').
      limit(12)
    render layout: 'two_columns'
  end


  # -------------------------------------------------------------
  # GET /workouts/new
  def new
    if cannot? :new, Workout
      redirect_to root_path,
        notice: 'Unauthorized to create new workout' and return
    end
    @workout = Workout.new
  end


  # -------------------------------------------------------------
  # GET /workouts/new_with_search/:searchkey
  def new_with_search
    @workout = Workout.new
    @exers = Exercise.find_by_sql(
      "SELECT * FROM exercises WHERE name LIKE '%#{params[:searchkey]}%'")
  end


  # -------------------------------------------------------------
  # GET /workouts/1/edit
  def edit
    if cannot? :edit, @workout
      redirect_to root_path, notice: 'Unauthorized to edit workout' and return
    end
    @exs = []
    @workout.exercises.each do |exer|
      @exs << exer.id
    end
    # Workout's EXERCISES
    @allexs = []
    Exercise.all.each do |exe|
      @allexs << exe.id
    end
    #ALL EXERCISES
  end


  # -------------------------------------------------------------
  # POST /workouts
  def create
    @workout = Workout.new(workout_params)
    msg      = params[:workout]
    exercises = msg[:exercise_workouts_attributes]
    @workout.creator_id = current_user.id
    exercises.each_with_index do |ex, index|
      ex_id = ex.second[:exercise_id]
      exercise = Exercise.find(ex_id)
      @workout.save!
      #@workout.exercises<<exercise

      #wek = @workout.exercise_workouts.find_by(exercise: exercise)
      wek = ExerciseWorkout.new
      wek.workout = @workout
      wek.exercise = exercise
      wek.order = index + 1
      wek.points = ex.second[:points]
      wek.save
    end

    course_offerings = msg[:workout_offerings_attributes]
    course_offerings.andand.each_with_index do |co, index|
      co_id = co.second[:course_offering_id]
      course_offering = CourseOffering.find(co_id)
      @workout.course_offerings<<course_offering
      @workout.save
      wo = @workout.workout_offerings.find_by(course_offering_id: co_id)
      wo.opening_date = Date.parse(co.second['opening_date(3i)'] +
        '-' + co.second['opening_date(2i)'] +
        '-' + co.second['opening_date(1i)'])
      wo.soft_deadline = Date.parse(co.second['soft_deadline(3i)'] +
        '-' + co.second['soft_deadline(2i)'] +
        '-' + co.second['soft_deadline(1i)'])
      wo.hard_deadline = Date.parse(co.second['hard_deadline(3i)'] +
        '-' + co.second['hard_deadline(2i)']+
        '-' + co.second['hard_deadline(1i)'])
      wo.save
    end

    if @workout.save
      redirect_to @workout, notice: 'Workout was successfully created.'
    else
      render action: 'new'
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
  def update
    if cannot? :update, @workout
      redirect_to root_path,
        notice: 'Unauthorized to update workout' and return
    end
    if @workout.update(workout_params)
      redirect_to @workout, notice: 'Workout was successfully updated.'
    else
      render action: 'edit'
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
  def practice_workout
    wid = params[:id]
    wkt = Workout.find(wid)
    if wkt
      if !user_signed_in?
        redirect_to workout_path(wkt),
          notice: "Need to Sign in to practice" and return
      end
      ex1 = wkt.next_exercise(nil,current_user)
      session[:current_workout] = wid
      session[:workout_feedback] = Hash.new
      session[:workout_feedback]['workout'] =
        "You have attempted Workout #{wkt.name}"
      redirect_to exercise_practice_path(id: ex1.id)
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


    # -------------------------------------------------------------
    # Only allow a trusted parameter "white list" through.
    def workout_params
      params.require(:workout).permit(:name, :scrambled, :exercise_ids,
        :description, :target_group, :points_multiplier, :opening_date,
        :exercise_workouts_attributes, :workout_offerings_attributes,
        :soft_deadline, :hard_deadline)
    end

end
