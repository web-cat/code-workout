class RenameOrderingToOrderInExerciseWorkouts < ActiveRecord::Migration
  def change
    rename_column :exercise_workouts, :ordering, :order
  end
end
