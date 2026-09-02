class RemoveIncorrectForeignKeyFromExerciseWorkouts < ActiveRecord::Migration[5.2]
  def change
    if foreign_key_exists?(:exercise_workouts, name: "fk_rails_d13b5486ee")
      remove_foreign_key :exercise_workouts, name: "fk_rails_d13b5486ee"
    end
  end
end
