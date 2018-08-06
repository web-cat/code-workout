class AddTextRepresentationToExerciseVersion < ActiveRecord::Migration
  def change
    add_column :exercise_versions, :text_representation, :text, limit: 16.megabytes - 1
  end
end
