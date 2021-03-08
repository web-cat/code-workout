class AddLanguageToExerciseWorkout < ActiveRecord::Migration
  def change
    add_column :exercise_workouts, :language, :string
  end
end
