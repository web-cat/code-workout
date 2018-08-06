class CreateExerciseWorkouts < ActiveRecord::Migration
  def change
    create_table :exercise_workouts do |t|
      t.integer :exercise_id
      t.integer :workout_id
      t.integer :order
      t.float :points

      t.timestamps
    end
  end
end
