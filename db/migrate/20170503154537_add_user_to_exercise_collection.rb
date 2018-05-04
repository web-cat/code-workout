class AddUserToExerciseCollection < ActiveRecord::Migration
  def change
    add_reference :exercise_collections, :user, index: true, foreign_key: true
  end
end
