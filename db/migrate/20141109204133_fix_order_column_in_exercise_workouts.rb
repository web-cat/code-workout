class FixOrderColumnInExerciseWorkouts < ActiveRecord::Migration
  def change
    rename_column :exercise_workouts, :order, :ordering
  end
end
