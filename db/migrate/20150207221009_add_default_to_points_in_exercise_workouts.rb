class AddDefaultToPointsInExerciseWorkouts < ActiveRecord::Migration
  def change
    change_column :exercise_workouts, :points, :float, default: 1.0
  end
end
