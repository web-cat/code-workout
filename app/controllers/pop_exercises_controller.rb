class PopExercisesController < ApplicationController
    respond_to :json

    def index
      @exercise = Popexercise.all
    end
  
    def show
      @exercise = Popexercise.find(params[:id])
    end
  
    def new
      @exercise = Popexercise.new
    end
  
    def edit
      @exercise = Popexercise.find(params[:id])
    end
  
    def create
      @exercise = Popexercise.new(exercise_params)
      if @exercise.save
        redirect_to @exercise
      else
        render 'new'
      end
  
    end
  
    def update
      @exercise = Popexercise.find(params[:id])
      if @exercise.update(exercise_params)
        redirect_to @exercise
      else
        render 'edit'
      end
    end
  
    def destroy
      @exercise = Popexercise.find(params[:id])
      @exercise.destroy
      redirect_to popexercises_path
    end
  
    private
    def exercise_params
      params.require(:popexercise).permit(:exercise_id, :code)
    end
  end
  
