class RenameOrderingToOrderInExerciseWorkouts < ActiveRecord::Migration[5.1]
  def change
    rename_column :exercise_workouts, :ordering, :order
  end
end
