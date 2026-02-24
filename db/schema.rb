# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2025_02_18_154318) do

  create_table "active_admin_comments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_id", null: false
    t.string "resource_type", null: false
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "attempts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "exercise_version_id", null: false
    t.datetime "submit_time", null: false
    t.integer "submit_num", null: false
    t.float "score", default: 0.0
    t.integer "experience_earned"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "workout_score_id"
    t.bigint "active_score_id"
    t.boolean "feedback_ready"
    t.decimal "time_taken", precision: 10
    t.decimal "feedback_timeout", precision: 10
    t.decimal "worker_time", precision: 10
    t.index ["active_score_id"], name: "index_attempts_on_active_score_id"
    t.index ["exercise_version_id"], name: "index_attempts_on_exercise_version_id"
    t.index ["user_id", "exercise_version_id"], name: "idx_attempts_on_user_exercise_version"
    t.index ["user_id"], name: "index_attempts_on_user_id"
    t.index ["workout_score_id", "exercise_version_id"], name: "idx_attempts_on_workout_score_exercise_version"
    t.index ["workout_score_id"], name: "index_attempts_on_workout_score_id"
  end

  create_table "attempts_tag_user_scores", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "attempt_id"
    t.bigint "tag_user_score_id"
    t.index ["attempt_id", "tag_user_score_id"], name: "attempts_tag_user_scores_idx", unique: true
    t.index ["attempt_id"], name: "index_attempts_tag_user_scores_on_attempt_id"
    t.index ["tag_user_score_id"], name: "index_attempts_tag_user_scores_on_tag_user_score_id"
  end

  create_table "choices", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "multiple_choice_prompt_id", null: false
    t.integer "position", null: false
    t.text "feedback"
    t.float "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "answer", null: false
    t.index ["multiple_choice_prompt_id"], name: "index_choices_on_multiple_choice_prompt_id"
  end

  create_table "choices_multiple_choice_prompt_answers", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "choice_id"
    t.bigint "multiple_choice_prompt_answer_id"
    t.index ["choice_id", "multiple_choice_prompt_answer_id"], name: "choices_multiple_choice_prompt_answers_idx", unique: true
    t.index ["choice_id"], name: "index_choices_multiple_choice_prompt_answers_on_choice_id"
    t.index ["multiple_choice_prompt_answer_id"], name: "prompt_answer_idx"
  end

  create_table "coding_prompt_answers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.text "answer"
    t.text "error"
    t.integer "error_line_no"
  end

  create_table "coding_prompts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "class_name"
    t.text "wrapper_code", null: false
    t.text "test_script", null: false
    t.string "method_name"
    t.text "starter_code"
    t.boolean "hide_examples", default: false, null: false
  end

  create_table "course_enrollments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "course_offering_id", null: false
    t.bigint "course_role_id", null: false
    t.index ["course_offering_id"], name: "index_course_enrollments_on_course_offering_id"
    t.index ["course_role_id"], name: "index_course_enrollments_on_course_role_id"
    t.index ["user_id", "course_offering_id"], name: "index_course_enrollments_on_user_id_and_course_offering_id", unique: true
    t.index ["user_id"], name: "index_course_enrollments_on_user_id"
  end

  create_table "course_exercises", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.bigint "exercise_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "course_exercises_course_id_fk"
    t.index ["exercise_id"], name: "course_exercises_exercise_id_fk"
  end

  create_table "course_offerings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.bigint "term_id", null: false
    t.string "label", null: false
    t.string "url"
    t.boolean "self_enrollment_allowed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "cutoff_date"
    t.bigint "lms_instance_id"
    t.index ["course_id"], name: "index_course_offerings_on_course_id"
    t.index ["lms_instance_id"], name: "index_course_offerings_on_lms_instance_id"
    t.index ["term_id"], name: "index_course_offerings_on_term_id"
  end

  create_table "course_offerings_workouts", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "course_offering_id", null: false
    t.bigint "workout_id", null: false
  end

  create_table "course_roles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "can_manage_course", default: false, null: false
    t.boolean "can_manage_assignments", default: false, null: false
    t.boolean "can_grade_submissions", default: false, null: false
    t.boolean "can_view_other_submissions", default: false, null: false
    t.boolean "builtin", default: false, null: false
  end

  create_table "courses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "number", null: false
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "creator_id"
    t.string "slug", null: false
    t.bigint "user_group_id"
    t.boolean "is_hidden", default: false
    t.index ["organization_id"], name: "index_courses_on_organization_id"
    t.index ["slug"], name: "index_courses_on_slug"
    t.index ["user_group_id"], name: "index_courses_on_user_group_id"
  end

  create_table "errors", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.string "usable_type"
    t.integer "usable_id"
    t.text "class_name"
    t.text "message"
    t.text "trace"
    t.text "target"
    t.text "referrer"
    t.text "params"
    t.text "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "status"
    t.index ["class_name"], name: "index_errors_on_class_name", length: 768
    t.index ["created_at"], name: "index_errors_on_created_at"
  end

  create_table "exercise_collections", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "user_group_id"
    t.bigint "license_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "course_offering_id"
    t.index ["course_offering_id"], name: "index_exercise_collections_on_course_offering_id"
    t.index ["license_id"], name: "index_exercise_collections_on_license_id"
    t.index ["user_group_id"], name: "index_exercise_collections_on_user_group_id"
    t.index ["user_id"], name: "index_exercise_collections_on_user_id"
  end

  create_table "exercise_families", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "exercise_owners", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "exercise_id", null: false
    t.bigint "owner_id", null: false
    t.index ["exercise_id", "owner_id"], name: "index_exercise_owners_on_exercise_id_and_owner_id", unique: true
    t.index ["exercise_id"], name: "index_exercise_owners_on_exercise_id"
    t.index ["owner_id"], name: "index_exercise_owners_on_owner_id"
  end

  create_table "exercise_versions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "stem_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "exercise_id", null: false
    t.integer "version", null: false
    t.bigint "creator_id"
    t.bigint "irt_data_id"
    t.text "text_representation", limit: 16777215
    t.index ["creator_id"], name: "exercise_versions_creator_id_fk"
    t.index ["exercise_id"], name: "index_exercise_versions_on_exercise_id"
    t.index ["irt_data_id"], name: "index_exercise_versions_on_irt_data_id"
    t.index ["stem_id"], name: "index_exercise_versions_on_stem_id"
  end

  create_table "exercise_versions_resource_files", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "exercise_version_id", null: false
    t.bigint "resource_file_id", null: false
    t.index ["exercise_version_id"], name: "index_exercise_versions_resource_files_on_exercise_version_id"
    t.index ["resource_file_id"], name: "index_exercise_versions_resource_files_on_resource_file_id"
  end

  create_table "exercise_workouts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "exercise_id", null: false
    t.bigint "workout_id", null: false
    t.integer "position", null: false
    t.float "points", default: 1.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id"], name: "exercise_workouts_exercise_id_fk"
    t.index ["workout_id"], name: "exercise_workouts_workout_id_fk"
  end

  create_table "exercises", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.integer "question_type", null: false
    t.bigint "current_version_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "versions"
    t.bigint "exercise_family_id"
    t.string "name"
    t.boolean "is_public", default: false, null: false
    t.integer "experience", null: false
    t.bigint "irt_data_id"
    t.string "external_id"
    t.bigint "exercise_collection_id"
    t.index ["current_version_id"], name: "index_exercises_on_current_version_id"
    t.index ["exercise_collection_id"], name: "index_exercises_on_exercise_collection_id"
    t.index ["exercise_family_id"], name: "index_exercises_on_exercise_family_id"
    t.index ["external_id"], name: "index_exercises_on_external_id", unique: true
    t.index ["irt_data_id"], name: "index_exercises_on_irt_data_id"
    t.index ["is_public"], name: "index_exercises_on_is_public"
  end

  create_table "exercises_workouts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "workout_id", null: false
    t.bigint "exercise_id", null: false
    t.integer "points"
    t.integer "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id"], name: "index_exercises_workouts_on_exercise_id"
    t.index ["workout_id"], name: "index_exercises_workouts_on_workout_id"
  end

  create_table "friendly_id_slugs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "global_roles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "can_manage_all_courses", default: false, null: false
    t.boolean "can_edit_system_configuration", default: false, null: false
    t.boolean "builtin", default: false, null: false
  end

  create_table "group_access_requests", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "user_group_id"
    t.boolean "pending", default: true
    t.boolean "decision"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_group_id"], name: "index_group_access_requests_on_user_group_id"
    t.index ["user_id"], name: "index_group_access_requests_on_user_id"
  end

  create_table "identities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid", "provider"], name: "index_identities_on_uid_and_provider"
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "irt_data", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.integer "attempt_count", null: false
    t.float "sum_of_scores", null: false
    t.float "difficulty", null: false
    t.float "discrimination", null: false
  end

  create_table "license_policies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.boolean "can_fork"
    t.boolean "is_public"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "licenses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "url"
    t.bigint "license_policy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["license_policy_id"], name: "index_licenses_on_license_policy_id"
  end

  create_table "lms_instances", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.string "consumer_key"
    t.string "consumer_secret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.bigint "lms_type_id"
    t.bigint "organization_id"
    t.index ["lms_type_id"], name: "index_lms_instances_on_lms_type_id"
    t.index ["organization_id"], name: "index_lms_instances_on_organization_id"
    t.index ["url"], name: "index_lms_instances_on_url", unique: true
  end

  create_table "lms_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_lms_types_on_name", unique: true
  end

  create_table "lti_identities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.string "lti_user_id"
    t.bigint "user_id"
    t.bigint "lms_instance_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lms_instance_id"], name: "index_lti_identities_on_lms_instance_id"
    t.index ["lti_user_id"], name: "index_lti_identities_on_lti_user_id"
    t.index ["user_id"], name: "index_lti_identities_on_user_id"
  end

  create_table "lti_workouts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "workout_id"
    t.string "lms_assignment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "lms_instance_id"
    t.index ["lms_instance_id"], name: "index_lti_workouts_on_lms_instance_id"
    t.index ["workout_id"], name: "index_lti_workouts_on_workout_id"
  end

  create_table "memberships", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "user_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "multiple_choice_prompt_answers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
  end

  create_table "multiple_choice_prompts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.boolean "allow_multiple", default: false, null: false
    t.boolean "is_scrambled", default: true, null: false
  end

  create_table "organizations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "abbreviation"
    t.string "slug", null: false
    t.boolean "is_hidden", default: false
    t.index ["name"], name: "index_organizations_on_name", unique: true
    t.index ["slug"], name: "index_organizations_on_slug", unique: true
  end

  create_table "ownerships", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.string "filename"
    t.bigint "resource_file_id"
    t.bigint "exercise_version_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_version_id"], name: "index_ownerships_on_exercise_version_id"
    t.index ["filename"], name: "index_ownerships_on_filename"
    t.index ["resource_file_id"], name: "index_ownerships_on_resource_file_id"
  end

  create_table "prompt_answers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "attempt_id"
    t.bigint "prompt_id"
    t.string "actable_type"
    t.bigint "actable_id"
    t.index ["actable_id"], name: "index_prompt_answers_on_actable_id"
    t.index ["actable_type", "actable_id"], name: "index_prompt_answers_on_actable_type_and_actable_id"
    t.index ["attempt_id", "prompt_id"], name: "index_prompt_answers_on_attempt_id_and_prompt_id", unique: true
    t.index ["attempt_id"], name: "index_prompt_answers_on_attempt_id"
    t.index ["prompt_id"], name: "index_prompt_answers_on_prompt_id"
  end

  create_table "prompts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "exercise_version_id", null: false
    t.text "question", null: false
    t.integer "position", null: false
    t.text "feedback"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "actable_type"
    t.bigint "actable_id"
    t.bigint "irt_data_id"
    t.index ["actable_id"], name: "index_prompts_on_actable_id"
    t.index ["actable_type", "actable_id"], name: "index_prompts_on_actable_type_and_actable_id"
    t.index ["exercise_version_id"], name: "index_prompts_on_exercise_version_id"
    t.index ["irt_data_id"], name: "index_prompts_on_irt_data_id"
  end

  create_table "resource_files", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.string "filename"
    t.string "token", null: false
    t.bigint "user_id", null: false
    t.boolean "public", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hashval"
    t.index ["hashval"], name: "index_resource_files_on_hashval"
    t.index ["token"], name: "index_resource_files_on_token"
    t.index ["user_id"], name: "index_resource_files_on_user_id"
  end

  create_table "stems", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.text "preamble"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "student_extensions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "workout_offering_id"
    t.datetime "soft_deadline"
    t.datetime "hard_deadline"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "time_limit"
    t.datetime "opening_date"
    t.index ["user_id"], name: "index_student_extensions_on_user_id"
    t.index ["workout_offering_id"], name: "index_student_extensions_on_workout_offering_id"
  end

  create_table "tag_user_scores", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "experience", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "completed_exercises", default: 0
    t.index ["experience"], name: "index_tag_user_scores_on_experience"
    t.index ["user_id"], name: "index_tag_user_scores_on_user_id"
  end

  create_table "taggings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "tag_id"
    t.string "taggable_type"
    t.bigint "taggable_id"
    t.string "tagger_type"
    t.bigint "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger_type_and_tagger_id"
  end

  create_table "tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", collation: "utf8mb3_bin"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "terms", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.integer "season", null: false
    t.date "starts_on", null: false
    t.date "ends_on", null: false
    t.integer "year", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug", null: false
    t.index ["slug"], name: "index_terms_on_slug", unique: true
    t.index ["starts_on"], name: "index_terms_on_starts_on"
    t.index ["year", "season"], name: "index_terms_on_year_and_season"
  end

  create_table "test_case_results", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "test_case_id", null: false
    t.bigint "user_id", null: false
    t.text "execution_feedback"
    t.integer "feedback_line_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "pass", null: false
    t.bigint "coding_prompt_answer_id"
    t.index ["coding_prompt_answer_id"], name: "index_test_case_results_on_coding_prompt_answer_id"
    t.index ["test_case_id"], name: "index_test_case_results_on_test_case_id"
    t.index ["user_id"], name: "index_test_case_results_on_user_id"
  end

  create_table "test_cases", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.text "negative_feedback"
    t.float "weight", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "coding_prompt_id", null: false
    t.text "input", null: false
    t.text "expected_output", null: false
    t.boolean "static", default: false, null: false
    t.boolean "screening", default: false, null: false
    t.boolean "example", default: false, null: false
    t.boolean "hidden", default: false, null: false
    t.index ["coding_prompt_id"], name: "index_test_cases_on_coding_prompt_id"
  end

  create_table "time_zones", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.string "name"
    t.string "zone"
    t.string "display_as"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.bigint "global_role_id", null: false
    t.string "avatar"
    t.string "slug", null: false
    t.bigint "time_zone_id"
    t.bigint "current_workout_score_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["current_workout_score_id"], name: "index_users_on_current_workout_score_id", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["global_role_id"], name: "index_users_on_global_role_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
    t.index ["time_zone_id"], name: "index_users_on_time_zone_id"
  end

  create_table "visualization_loggings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "exercise_id"
    t.bigint "workout_id"
    t.bigint "workout_offering_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id"], name: "index_visualization_loggings_on_exercise_id"
    t.index ["user_id"], name: "index_visualization_loggings_on_user_id"
    t.index ["workout_id"], name: "index_visualization_loggings_on_workout_id"
    t.index ["workout_offering_id"], name: "index_visualization_loggings_on_workout_offering_id"
  end

  create_table "workout_offerings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "course_offering_id", null: false
    t.bigint "workout_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "opening_date"
    t.datetime "soft_deadline"
    t.datetime "hard_deadline"
    t.boolean "published", default: true, null: false
    t.integer "time_limit"
    t.bigint "workout_policy_id"
    t.bigint "continue_from_workout_id"
    t.string "lms_assignment_id"
    t.boolean "most_recent", default: true
    t.string "lms_assignment_url"
    t.integer "attempt_limit"
    t.index ["continue_from_workout_id"], name: "workout_offerings_continue_from_workout_id_fk"
    t.index ["course_offering_id"], name: "index_workout_offerings_on_course_offering_id"
    t.index ["lms_assignment_id"], name: "index_workout_offerings_on_lms_assignment_id"
    t.index ["workout_id"], name: "index_workout_offerings_on_workout_id"
    t.index ["workout_policy_id"], name: "index_workout_offerings_on_workout_policy_id"
  end

  create_table "workout_owners", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "workout_id", null: false
    t.bigint "owner_id", null: false
    t.index ["owner_id"], name: "workout_owners_owner_id_fk"
    t.index ["workout_id", "owner_id"], name: "index_workout_owners_on_workout_id_and_owner_id", unique: true
    t.index ["workout_id"], name: "index_workout_owners_on_workout_id"
  end

  create_table "workout_policies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.boolean "hide_thumbnails_before_start"
    t.boolean "hide_feedback_before_finish"
    t.boolean "hide_compilation_feedback_before_finish"
    t.boolean "no_review_before_close"
    t.boolean "hide_feedback_in_review_before_close"
    t.boolean "hide_thumbnails_in_review_before_close"
    t.boolean "no_hints"
    t.boolean "no_faq"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "invisible_before_review"
    t.string "description"
    t.boolean "hide_score_before_finish"
    t.boolean "hide_score_in_review_before_close"
  end

  create_table "workout_scores", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "workout_id", null: false
    t.bigint "user_id", null: false
    t.float "score"
    t.boolean "completed"
    t.timestamp "completed_at"
    t.timestamp "last_attempted_at"
    t.integer "exercises_completed"
    t.integer "exercises_remaining"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "workout_offering_id"
    t.string "lis_outcome_service_url"
    t.string "lis_result_sourcedid"
    t.bigint "lti_workout_id"
    t.datetime "started_at"
    t.index ["lti_workout_id"], name: "index_workout_scores_on_lti_workout_id"
    t.index ["user_id", "workout_id", "workout_offering_id"], name: "idx_ws_on_user_workout_workout_offering"
    t.index ["user_id"], name: "index_workout_scores_on_user_id"
    t.index ["workout_id"], name: "index_workout_scores_on_workout_id"
    t.index ["workout_offering_id"], name: "index_workout_scores_on_workout_offering_id"
  end

  create_table "workouts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "scrambled", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.integer "points_multiplier"
    t.bigint "creator_id"
    t.string "external_id"
    t.boolean "is_public"
    t.index ["creator_id"], name: "workouts_creator_id_fk"
    t.index ["external_id"], name: "index_workouts_on_external_id", unique: true
    t.index ["is_public"], name: "index_workouts_on_is_public"
  end

  add_foreign_key "attempts", "exercise_versions"
  add_foreign_key "attempts", "exercise_versions", name: "attempts_exercise_version_id_fk"
  add_foreign_key "attempts", "users"
  add_foreign_key "attempts", "users", name: "attempts_user_id_fk"
  add_foreign_key "attempts", "workout_scores", column: "active_score_id", name: "attempts_active_score_id_fk"
  add_foreign_key "attempts", "workout_scores", name: "attempts_workout_score_id_fk"
  add_foreign_key "attempts_tag_user_scores", "attempts", name: "attempts_tag_user_scores_attempt_id_fk"
  add_foreign_key "attempts_tag_user_scores", "tag_user_scores", name: "attempts_tag_user_scores_tag_user_score_id_fk"
  add_foreign_key "choices", "multiple_choice_prompts"
  add_foreign_key "choices", "multiple_choice_prompts", name: "choices_multiple_choice_prompt_id_fk"
  add_foreign_key "choices_multiple_choice_prompt_answers", "choices", name: "choices_multiple_choice_prompt_answers_choice_id_fk"
  add_foreign_key "choices_multiple_choice_prompt_answers", "multiple_choice_prompt_answers", name: "choices_MC_prompt_answers_MC_prompt_answer_id_fk"
  add_foreign_key "course_enrollments", "course_offerings"
  add_foreign_key "course_enrollments", "course_offerings", name: "course_enrollments_course_offering_id_fk"
  add_foreign_key "course_enrollments", "course_roles"
  add_foreign_key "course_enrollments", "course_roles", name: "course_enrollments_course_role_id_fk"
  add_foreign_key "course_enrollments", "users"
  add_foreign_key "course_enrollments", "users", name: "course_enrollments_user_id_fk"
  add_foreign_key "course_exercises", "courses"
  add_foreign_key "course_exercises", "courses", name: "course_exercises_course_id_fk"
  add_foreign_key "course_exercises", "exercise_versions", column: "exercise_id"
  add_foreign_key "course_exercises", "exercises", name: "course_exercises_exercise_id_fk"
  add_foreign_key "course_offerings", "courses"
  add_foreign_key "course_offerings", "courses", name: "course_offerings_course_id_fk"
  add_foreign_key "course_offerings", "terms"
  add_foreign_key "course_offerings", "terms", name: "course_offerings_term_id_fk"
  add_foreign_key "courses", "organizations"
  add_foreign_key "courses", "organizations", name: "courses_organization_id_fk"
  add_foreign_key "courses", "user_groups"
  add_foreign_key "exercise_collections", "course_offerings"
  add_foreign_key "exercise_collections", "licenses"
  add_foreign_key "exercise_collections", "user_groups"
  add_foreign_key "exercise_collections", "users"
  add_foreign_key "exercise_owners", "exercises"
  add_foreign_key "exercise_owners", "exercises", name: "exercise_owners_exercise_id_fk"
  add_foreign_key "exercise_owners", "users", column: "owner_id"
  add_foreign_key "exercise_owners", "users", column: "owner_id", name: "exercise_owners_owner_id_fk"
  add_foreign_key "exercise_versions", "exercises"
  add_foreign_key "exercise_versions", "exercises", name: "exercise_versions_exercise_id_fk"
  add_foreign_key "exercise_versions", "irt_data", column: "irt_data_id"
  add_foreign_key "exercise_versions", "irt_data", column: "irt_data_id", name: "exercise_versions_irt_data_id_fk"
  add_foreign_key "exercise_versions", "stems"
  add_foreign_key "exercise_versions", "stems", name: "exercise_versions_stem_id_fk"
  add_foreign_key "exercise_versions", "users", column: "creator_id", name: "exercise_versions_creator_id_fk"
  add_foreign_key "exercise_versions_resource_files", "exercise_versions"
  add_foreign_key "exercise_versions_resource_files", "exercise_versions", name: "exercise_versions_resource_files_exercise_version_id_fk"
  add_foreign_key "exercise_versions_resource_files", "resource_files"
  add_foreign_key "exercise_versions_resource_files", "resource_files", name: "exercise_versions_resource_files_resource_file_id_fk"
  add_foreign_key "exercise_workouts", "exercise_versions", column: "exercise_id"
  add_foreign_key "exercise_workouts", "exercises", name: "exercise_workouts_exercise_id_fk"
  add_foreign_key "exercise_workouts", "workouts"
  add_foreign_key "exercise_workouts", "workouts", name: "exercise_workouts_workout_id_fk"
  add_foreign_key "exercises", "exercise_collections"
  add_foreign_key "exercises", "exercise_families"
  add_foreign_key "exercises", "exercise_families", name: "exercises_exercise_family_id_fk"
  add_foreign_key "exercises", "exercise_versions", column: "current_version_id"
  add_foreign_key "exercises", "exercise_versions", column: "current_version_id", name: "exercises_current_version_id_fk"
  add_foreign_key "exercises", "irt_data", column: "irt_data_id"
  add_foreign_key "exercises", "irt_data", column: "irt_data_id", name: "exercises_irt_data_id_fk"
  add_foreign_key "group_access_requests", "user_groups"
  add_foreign_key "group_access_requests", "users"
  add_foreign_key "identities", "users"
  add_foreign_key "identities", "users", name: "identities_user_id_fk"
  add_foreign_key "licenses", "license_policies"
  add_foreign_key "lms_instances", "lms_types"
  add_foreign_key "lti_workouts", "lms_instances"
  add_foreign_key "ownerships", "exercise_versions"
  add_foreign_key "ownerships", "resource_files"
  add_foreign_key "prompt_answers", "attempts", name: "prompt_answers_attempt_id_fk"
  add_foreign_key "prompt_answers", "prompts", name: "prompt_answers_prompt_id_fk"
  add_foreign_key "prompts", "exercise_versions"
  add_foreign_key "prompts", "exercise_versions", name: "prompts_exercise_version_id_fk"
  add_foreign_key "prompts", "irt_data", column: "irt_data_id"
  add_foreign_key "prompts", "irt_data", column: "irt_data_id", name: "prompts_irt_data_id_fk"
  add_foreign_key "resource_files", "users"
  add_foreign_key "resource_files", "users", name: "resource_files_user_id_fk"
  add_foreign_key "student_extensions", "users", name: "student_extensions_user_id_fk"
  add_foreign_key "student_extensions", "workout_offerings", name: "student_extensions_workout_offering_id_fk"
  add_foreign_key "tag_user_scores", "users"
  add_foreign_key "tag_user_scores", "users", name: "tag_user_scores_user_id_fk"
  add_foreign_key "test_case_results", "coding_prompt_answers", name: "test_case_results_coding_prompt_answer_id_fk"
  add_foreign_key "test_case_results", "test_cases"
  add_foreign_key "test_case_results", "test_cases", name: "test_case_results_test_case_id_fk"
  add_foreign_key "test_case_results", "users"
  add_foreign_key "test_case_results", "users", name: "test_case_results_user_id_fk"
  add_foreign_key "test_cases", "coding_prompts"
  add_foreign_key "test_cases", "coding_prompts", name: "test_cases_coding_prompt_id_fk"
  add_foreign_key "users", "global_roles"
  add_foreign_key "users", "global_roles", name: "users_global_role_id_fk"
  add_foreign_key "users", "time_zones", name: "users_time_zone_id_fk"
  add_foreign_key "users", "workout_scores", column: "current_workout_score_id"
  add_foreign_key "users", "workout_scores", column: "current_workout_score_id", name: "users_current_workout_score_id_fk"
  add_foreign_key "workout_offerings", "course_offerings"
  add_foreign_key "workout_offerings", "course_offerings", name: "workout_offerings_course_offering_id_fk"
  add_foreign_key "workout_offerings", "workout_offerings", column: "continue_from_workout_id"
  add_foreign_key "workout_offerings", "workout_offerings", column: "continue_from_workout_id", name: "workout_offerings_continue_from_workout_id_fk"
  add_foreign_key "workout_offerings", "workout_policies", name: "workout_offerings_workout_policy_id_fk"
  add_foreign_key "workout_offerings", "workouts"
  add_foreign_key "workout_offerings", "workouts", name: "workout_offerings_workout_id_fk"
  add_foreign_key "workout_owners", "users", column: "owner_id"
  add_foreign_key "workout_owners", "users", column: "owner_id", name: "workout_owners_owner_id_fk"
  add_foreign_key "workout_owners", "workouts"
  add_foreign_key "workout_owners", "workouts", name: "workout_owners_workout_id_fk"
  add_foreign_key "workout_scores", "lti_workouts"
  add_foreign_key "workout_scores", "users"
  add_foreign_key "workout_scores", "users", name: "workout_scores_user_id_fk"
  add_foreign_key "workout_scores", "workout_offerings"
  add_foreign_key "workout_scores", "workout_offerings", name: "workout_scores_workout_offering_id_fk"
  add_foreign_key "workout_scores", "workouts"
  add_foreign_key "workout_scores", "workouts", name: "workout_scores_workout_id_fk"
  add_foreign_key "workouts", "users", column: "creator_id", name: "workouts_creator_id_fk"
end
