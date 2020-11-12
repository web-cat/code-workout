class FixOrderColumnInExerciseWorkouts < ActiveRecord::Migration[5.1]
  def change
    rename_column :exercise_workouts, :order, :ordering
  end
end
