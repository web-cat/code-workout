class AddNullConstraintsAndIndices < ActiveRecord::Migration
  def change
    # identities
    change_column_null :identities, :user_id, false
    change_column_null :identities, :provider, false
    change_column_null :identities, :uid, false
    add_index :identities, [:uid, :provider]

    # organizations
    change_column_null :organizations, :display_name, false
    change_column_null :organizations, :url_part, false

    # courses
    change_column_null :courses, :name, false
    change_column_null :courses, :number, false
    change_column_null :courses, :organization_id, false
    change_column_null :courses, :url_part, false

    # course_offerings
    change_column_null :course_offerings, :name, false
    change_column_null :course_offerings, :course_id, false
    change_column_null :course_offerings, :term_id, false

    # terms
    change_column_null :terms, :season, false
    change_column_null :terms, :year, false
    change_column_null :terms, :starts_on, false
    change_column_null :terms, :ends_on, false
    add_index :terms, [:year, :season]

    # course_enrollments
    change_column_null :course_enrollments, :user_id, false
    change_column_null :course_enrollments, :course_offering_id, false
    change_column_null :course_enrollments, :course_role_id, false

    # variation_groups
    change_column_null :variation_groups, :title, false

    # base_exercises
    change_column_null :base_exercises, :question_type, false
    change_column_null :base_exercises, :versions, false
    change_column_null :base_exercises, :current_version_id, false
    add_index :base_exercises, :user_id
    add_index :base_exercises, :current_version_id
    add_index :base_exercises, :variation_group_id

    # choices
    change_column_null :choices, :answer, false
    change_column_null :choices, :order, false
    change_column_null :choices, :value, false

    # coding_questions
    change_column_null :coding_questions, :exercise_id, false
    change_column_null :coding_questions, :wrapper_code, false
    change_column_null :coding_questions, :test_script, false

    # course_exercises
    change_column_null :course_exercises, :course_id, false
    change_column_null :course_exercises, :exercise_id, false

    # exercise_workouts
    change_column_null :exercise_workouts, :exercise_id, false
    change_column_null :exercise_workouts, :workout_id, false
    change_column_null :exercise_workouts, :ordering, false

    # exercises
    change_column_null :exercises, :base_exercise_id, false
    change_column_null :exercises, :title, false
    change_column_null :exercises, :experience, false
    change_column_null :exercises, :version, false

    # exercises_resource_files
    change_column_null :exercises_resource_files, :exercise_id, false
    change_column_null :exercises_resource_files, :resource_file_id, false
    add_index :exercises_resource_files, :exercise_id
    add_index :exercises_resource_files, :resource_file_id

    # exercises_tags
    change_column_null :exercises_tags, :exercise_id, false
    change_column_null :exercises_tags, :tag_id, false
    add_index :exercises_tags, :exercise_id
    add_index :exercises_tags, :tag_id

    # prompts
    change_column_null :prompts, :max_user_attempts, false
    change_column_null :prompts, :attempts, false
    change_column_null :prompts, :correct, false

    # resource_files
    change_column_null :resource_files, :user_id, false
    change_column_null :resource_files, :token, false
    add_index :resource_files, :user_id
    add_index :resource_files, :token

    # tags_workouts
    change_column_null :tags_workouts, :tag_id, false
    change_column_null :tags_workouts, :workout_id, false

    # test_case_results
    change_column_null :test_case_results, :user_id, false
    change_column_null :test_case_results, :test_case_id, false
    change_column_null :test_case_results, :pass, false
    add_index :test_case_results, :user_id
    add_index :test_case_results, :test_case_id

    # test_cases
    change_column_null :test_cases, :input, false
    change_column_null :test_cases, :expected_output, false
    change_column_null :test_cases, :negative_feedback, false
    change_column_null :test_cases, :coding_question_id, false
    change_column_null :test_cases, :weight, false

    # users
    change_column_null :users, :global_role_id, false

    # workout_offerings
    change_column_null :workout_offerings, :course_offering_id, false
    change_column_null :workout_offerings, :workout_id, false
    add_index :workout_offerings, :course_offering_id
    add_index :workout_offerings, :workout_id

    # workout_scores
    change_column_null :workout_scores, :user_id, false
    change_column_null :workout_scores, :workout_id, false

  end
end
