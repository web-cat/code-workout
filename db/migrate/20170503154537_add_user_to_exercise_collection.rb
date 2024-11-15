class AddUserToExerciseCollection < ActiveRecord::Migration[5.1]
  def change
    add_reference :exercise_collections, :user, index: true, foreign_key: true
  end
end
