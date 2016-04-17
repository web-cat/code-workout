class HintsController < ApplicationController

  def new
    allow = false
    if current_user.global_role_id < 3
      allow = true
    elsif params[:exercise_version_id]
       exercise = ExerciseVersion.find(params[:exercise_version_id]).exercise
       attempts = Attempt.where(exercise_version_id: params[:exercise_version_id], user: current_user)
       attempts.each do |attempt|
         ExerciseWorkout.where(exercise: exercise, workout: attempt.andand.workout_score.workout).each do |exw|
           allow = true if attempt.score == exw.points
         end 
       end
       binding.pry
    end
    if allow
      @exercise_version = ExerciseVersion.find(params[:exercise_version_id])
      @hint = Hint.new
    else
      redirect_to root_path, notice: 'You are not allowed to create hints'
    end
  end
  
  def destroy
    Hint.destroy(params[:id])
    redirect_to root_path, notice: 'Hint removed'
  end
  
  def create
    hint = Hint.new(user: current_user, body: params[:hint][:body], exercise_version: ExerciseVersion.find(params[:hint][:exercise_version_id]), curated: false)
    if hint.save
      redirect_to root_path, notice: 'Hint has been created and is awaiting the instructor\'s approval'
    else
      redirect_to root_path, notice: 'Hint creation failed'
    end
  end
    
  def approve_hint
    hint = Hint.find(params[:hint_id])
    hint.curated = true
    hint.save!
    redirect_to root_path, notice: 'The hint has been approved'
  end
  
   private

   def hint_params
      params.require(:hint).permit(:body, :exercise_version, :params, :button)
   end
end