class AddForeignKeyConstraints < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :attempts, :exercises, dependent: :delete
    add_foreign_key :attempts, :users, dependent: :delete
    change_column :base_exercises, :current_version_id, :bigint
    add_foreign_key :base_exercises, :exercises, column: :current_version_id
    change_column :base_exercises, :user_id, :bigint
    add_foreign_key :base_exercises, :users
    change_column :base_exercises, :variation_group_id, :bigint
    add_foreign_key :base_exercises, :variation_groups
    add_foreign_key :choices, :exercises, dependent: :delete
    add_foreign_key :coding_questions, :exercises, dependent: :delete
    add_foreign_key :course_enrollments, :course_offerings, dependent: :delete
    add_foreign_key :course_enrollments, :course_roles
    add_foreign_key :course_enrollments, :users, dependent: :delete
    change_column :course_exercises, :course_id, :bigint
    add_foreign_key :course_exercises, :courses, dependent: :delete
    change_column :course_exercises, :exercise_id, :bigint
    add_foreign_key :course_exercises, :exercises, dependent: :delete
    add_foreign_key :course_offerings, :courses, dependent: :delete
    add_foreign_key :course_offerings, :terms, dependent: :delete
    add_foreign_key :courses, :organizations, dependent: :delete
    change_column :exercise_workouts, :exercise_id, :bigint
    add_foreign_key :exercise_workouts, :exercises, dependent: :delete
    change_column :exercise_workouts, :workout_id, :bigint
    add_foreign_key :exercise_workouts, :workouts, dependent: :delete
    change_column :exercises, :base_exercise_id, :bigint
    add_foreign_key :exercises, :base_exercises, dependent: :delete
    add_foreign_key :exercises_resource_files, :exercises, dependent: :delete
    add_foreign_key :exercises_resource_files, :resource_files,
      dependent: :delete
    add_foreign_key :exercises, :stems
    add_foreign_key :exercises_tags, :exercises, dependent: :delete
    add_foreign_key :exercises_tags, :tags, dependent: :delete
    add_foreign_key :identities, :users, dependent: :delete
    add_foreign_key :prompts, :exercises, dependent: :delete
    add_foreign_key :resource_files, :users
    add_foreign_key :tag_user_scores, :tags, dependent: :delete
    add_foreign_key :tag_user_scores, :users, dependent: :delete
    add_foreign_key :tags_workouts, :tags, dependent: :delete
    add_foreign_key :tags_workouts, :workouts, dependent: :delete
    change_column :test_case_results, :test_case_id, :bigint
    add_foreign_key :test_case_results, :test_cases, dependent: :delete
    change_column :test_case_results, :user_id, :bigint
    add_foreign_key :test_case_results, :users, dependent: :delete
    add_foreign_key :test_cases, :coding_questions, dependent: :delete
    add_foreign_key :users, :global_roles
    change_column :workout_offerings, :course_offering_id, :bigint
    add_foreign_key :workout_offerings, :course_offerings, dependent: :delete
    change_column :workout_offerings, :workout_id, :bigint
    add_foreign_key :workout_offerings, :workouts, dependent: :delete
    add_foreign_key :workout_scores, :users, dependent: :delete
    add_foreign_key :workout_scores, :workouts, dependent: :delete
  end
end
