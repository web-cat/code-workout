class AddExerciseCollectionToExercises < ActiveRecord::Migration[5.1]
  def change
    add_reference :exercises, :exercise_collection, index: true, foreign_key: true
  end
end
