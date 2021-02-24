class AddAssociatedIdToExerciseVersion < ActiveRecord::Migration
  def change
    add_column :exercise_versions, :associated_id, :integer
  end
end
