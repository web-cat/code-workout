class RenameExercisesToExerciseVersions < ActiveRecord::Migration
  def change
    rename_table :exercises, :exercise_versions
    rename_column :attempts, :exercise_id, :exercise_version_id
    rename_column :choices, :exercise_id, :exercise_version_id
    rename_column :coding_questions, :exercise_id, :exercise_version_id
    rename_column :prompts, :exercise_id, :exercise_version_id

    rename_table :course_exercises, :course_base_exercises
    rename_column :course_base_exercises, :exercise_id, :base_exercise_id

    rename_table :exercise_workouts, :base_exercise_workouts
    rename_column :base_exercise_workouts, :exercise_id, :base_exercise_id

    rename_table :exercises_tags, :exercise_versions_tags
    rename_column :exercise_versions_tags, :exercise_id, :exercise_version_id

    rename_table :exercises_resource_files, :exercise_versions_resource_files
    rename_column :exercise_versions_resource_files,
      :exercise_id, :exercise_version_id
  end
end
