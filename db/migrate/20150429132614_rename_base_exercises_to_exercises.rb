class RenameBaseExercisesToExercises < ActiveRecord::Migration
  def change
    rename_table :base_exercises, :exercises
    rename_column :exercise_versions, :base_exercise_id, :exercise_id

    rename_table :base_exercise_workouts, :exercise_workouts
    rename_column :exercise_workouts, :base_exercise_id, :exercise_id

    rename_table :course_base_exercises, :course_exercises
    rename_column :course_exercises, :base_exercise_id, :exercise_id
  end
end
