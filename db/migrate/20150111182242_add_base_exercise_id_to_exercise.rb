class AddBaseExerciseIdToExercise < ActiveRecord::Migration
  def change
    add_column :exercises, :base_exercise_id, :integer
    add_index :exercises, :base_exercise_id
  end
end
