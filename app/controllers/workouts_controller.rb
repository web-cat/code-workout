class WorkoutsController < ApplicationController
  before_action :set_workout, only: [:show, :edit, :update, :destroy]

  # GET /workouts
  def index
    @workouts = Workout.all
  end

  # GET /workouts/1
  def show
    if( params[:id] )
      found = Workout.where(:id => params[:id])
      if( found.empty? )
        redirect_to workouts_url, notice: "Workout #{params[:id]} not found"
      else
        @workout = found.first
      end
    else
      redirect_to workouts_url, notice: 'Choose a workout for practice!'
    end
    render layout: 'two_columns'
  end

  # GET /workouts/new
  def new
    @workout = Workout.new
  end

  # GET /workouts/1/edit
  def edit
  end

  # POST /workouts
  def create
    @workout = Workout.new(workout_params)

    if @workout.save
      redirect_to @workout, notice: 'Workout was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /workouts/1
  def update
    if @workout.update(workout_params)
      redirect_to @workout, notice: 'Workout was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /workouts/1
  def destroy
    @workout.destroy
    redirect_to workouts_url, notice: 'Workout was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_workout
      @workout = Workout.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def workout_params
      params[:workout]
    end
end
