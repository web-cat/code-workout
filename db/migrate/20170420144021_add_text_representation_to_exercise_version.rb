class AddTextRepresentationToExerciseVersion < ActiveRecord::Migration[5.1]
  def change
    add_column :exercise_versions, :text_representation, :text, limit: 16.megabytes - 1
  end
end
