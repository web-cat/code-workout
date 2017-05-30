class AddExerciseCollectionToExercises < ActiveRecord::Migration
  def change
    add_reference :exercises, :exercise_collection, index: true, foreign_key: true
  end
end
