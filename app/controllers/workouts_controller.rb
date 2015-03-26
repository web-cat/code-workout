class WorkoutsController < ApplicationController
  before_action :set_workout, only: [:show, :edit, :update, :destroy]


  #~ Public instance methods ..................................................

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


  # GET /workouts/download.json
  def download
    if cannot? :index, Workout
      redirect_to root_path,
        notice: 'Unauthorized to view all workouts' and return
    end
    @workouts = Workout.all
    respond_to do |format|
      format.json
    end
  end


  # GET /workouts/1
  def show
    if params[:id]
      found = Workout.where(id: params[:id])
      if found.empty?
        redirect_to workouts_url, notice: "Workout #{params[:id]} not found"
      else
        @workouts = found #.first
        @exs = found.first.exercises.sort_by{ |a| a[:order] }
      end
    else
      redirect_to workouts_url, notice: 'Choose a workout for practice!'
    end
    # render layout: 'two_columns'
  end


  # GET /gym
  def gym
    @gym = Workout.order('created_at DESC').limit(12)
    render layout: 'two_columns'
  end


  # GET /workouts/new
  def new
    if cannot? :new, Workout
      redirect_to root_path,
        notice: 'Unauthorized to create new workout' and return
    end
    @workout = Workout.new
  end


  # GET /workouts/new_with_search/:searchkey
  def new_with_search
    @workout = Workout.new
    @exers = Exercise.find_by_sql(
      "SELECT * FROM exercises WHERE name LIKE '%#{params[:searchkey]}%'")
  end


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


  # POST /workouts
  def create
    @workout = Workout.new(workout_params)
    msg      = params[:workout]
    exerciseids = msg[:exercise_ids]
    @workout.creator_id = current_user.id
    exerciseids.each_with_index do |ex, index|
      if index > 0
        exercise = Exercise.find(ex)
        @workout.exercises<<exercise
        @workout.save
        wek = @workout.exercise_workouts.find_by_sql(
          "select * from exercise_workouts where exercise_id=#{ex}")
        wek.last.order = index
        wek.last.points = msg[:points_multiplier]
        wek.last.save
      end
    end

    if @workout.save
      redirect_to @workout, notice: 'Workout was successfully created.'
    else
      render action: 'new'
    end
  end


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


  # DELETE /workouts/1
  def destroy
    if cannot? :destroy, @workout
      redirect_to root_path,
        notice: 'Unauthorized to destroy workout' and return
    end
    @workout.destroy
    redirect_to workouts_url, notice: 'Workout was successfully destroyed.'
  end


  def practice_workout
    wid = params[:id]
    wkt = Workout.find(wid)
    if wkt
      if !user_signed_in?
        redirect_to workout_path(wkt),
          notice: "Need to Sign in to practice" and return
      end
      ex1 = wkt.exercises.first
      session[:current_workout] = wid
      session[:workout_feedback] = Hash.new
      session[:workout_feedback]['workout'] =
        "You have attempted Workout #{wkt.name}"
      session[:wexes] = wkt.exercises.ids[1..-1]
      session[:remaining_wexes] = session[:wexes]
      redirect_to exercise_practice_path(
        id: ex1.id, wexes: wkt.exercises.ids[1..-1])
    else
      redirect_to workouts, notice: 'Workout not found' and return
    end
  end


  #~ Private instance methods .................................................

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_workout
    @workout = Workout.find(params[:id])
    @xp = 30
    @xptogo = 60
    @remain = 10
  end


  # Only allow a trusted parameter "white list" through.
  def workout_params
    params.require(:workout).permit(:name, :scrambled, :exercise_ids,
      :description, :target_group, :points_multiplier, :opening_date,
      :soft_deadline, :hard_deadline)
  end

end
