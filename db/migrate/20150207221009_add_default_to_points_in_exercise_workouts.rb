class AddDefaultToPointsInExerciseWorkouts < ActiveRecord::Migration[5.1]
  def change
    change_column :exercise_workouts, :points, :float, default: 1.0
  end
end
