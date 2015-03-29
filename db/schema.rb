# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150328150855) do

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"

  create_table "attempts", force: true do |t|
    t.integer  "user_id",                           null: false
    t.integer  "exercise_id",                       null: false
    t.datetime "submit_time",                       null: false
    t.integer  "submit_num",                        null: false
    t.text     "answer"
    t.decimal  "score",               default: 0.0
    t.integer  "experience_earned"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "workout_offering_id"
  end

  add_index "attempts", ["exercise_id"], name: "index_attempts_on_exercise_id"
  add_index "attempts", ["user_id"], name: "index_attempts_on_user_id"

  create_table "base_exercises", force: true do |t|
    t.integer  "user_id"
    t.integer  "question_type",      null: false
    t.integer  "current_version_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "versions",           null: false
    t.integer  "variation_group_id"
  end

  add_index "base_exercises", ["current_version_id"], name: "index_base_exercises_on_current_version_id"
  add_index "base_exercises", ["user_id"], name: "index_base_exercises_on_user_id"
  add_index "base_exercises", ["variation_group_id"], name: "index_base_exercises_on_variation_group_id"

  create_table "choices", force: true do |t|
    t.integer  "exercise_id", null: false
    t.string   "answer",      null: false
    t.integer  "order",       null: false
    t.text     "feedback"
    t.float    "value",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "choices", ["exercise_id"], name: "index_choices_on_exercise_id"

  create_table "coding_questions", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "exercise_id",  null: false
    t.string   "class_name"
    t.text     "wrapper_code", null: false
    t.text     "test_script",  null: false
    t.string   "method_name"
    t.text     "starter_code"
  end

  add_index "coding_questions", ["exercise_id"], name: "index_coding_questions_on_exercise_id"

  create_table "course_enrollments", force: true do |t|
    t.integer "user_id",            null: false
    t.integer "course_offering_id", null: false
    t.integer "course_role_id",     null: false
  end

  add_index "course_enrollments", ["course_offering_id"], name: "index_course_enrollments_on_course_offering_id"
  add_index "course_enrollments", ["course_role_id"], name: "index_course_enrollments_on_course_role_id"
  add_index "course_enrollments", ["user_id", "course_offering_id"], name: "index_course_enrollments_on_user_id_and_course_offering_id", unique: true
  add_index "course_enrollments", ["user_id"], name: "index_course_enrollments_on_user_id"

  create_table "course_exercises", force: true do |t|
    t.integer  "course_id",   null: false
    t.integer  "exercise_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "course_offerings", force: true do |t|
    t.integer  "course_id",               null: false
    t.integer  "term_id",                 null: false
    t.string   "label",                   null: false
    t.string   "url"
    t.boolean  "self_enrollment_allowed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "course_offerings", ["course_id"], name: "index_course_offerings_on_course_id"
  add_index "course_offerings", ["term_id"], name: "index_course_offerings_on_term_id"

  create_table "course_roles", force: true do |t|
    t.string  "name",                                       null: false
    t.boolean "can_manage_course",          default: false, null: false
    t.boolean "can_manage_assignments",     default: false, null: false
    t.boolean "can_grade_submissions",      default: false, null: false
    t.boolean "can_view_other_submissions", default: false, null: false
    t.boolean "builtin",                    default: false, null: false
  end

  create_table "courses", force: true do |t|
    t.string   "name",            null: false
    t.string   "number",          null: false
    t.integer  "organization_id", null: false
    t.string   "url_part",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
  end

  add_index "courses", ["organization_id"], name: "index_courses_on_organization_id"
  add_index "courses", ["url_part"], name: "index_courses_on_url_part"

  create_table "exercise_workouts", force: true do |t|
    t.integer  "exercise_id",               null: false
    t.integer  "workout_id",                null: false
    t.integer  "order",                     null: false
    t.float    "points",      default: 1.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exercises", force: true do |t|
    t.integer  "stem_id"
    t.string   "name",               null: false
    t.text     "question",           null: false
    t.text     "feedback"
    t.boolean  "is_public",          null: false
    t.integer  "priority",           null: false
    t.integer  "count_attempts",     null: false
    t.float    "count_correct",      null: false
    t.float    "difficulty",         null: false
    t.float    "discrimination",     null: false
    t.boolean  "mcq_allow_multiple"
    t.boolean  "mcq_is_scrambled"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "experience",         null: false
    t.integer  "base_exercise_id",   null: false
    t.integer  "version",            null: false
    t.integer  "creator_id"
  end

  add_index "exercises", ["base_exercise_id"], name: "index_exercises_on_base_exercise_id"
  add_index "exercises", ["stem_id"], name: "index_exercises_on_stem_id"

  create_table "exercises_resource_files", id: false, force: true do |t|
    t.integer "exercise_id",      null: false
    t.integer "resource_file_id", null: false
  end

  add_index "exercises_resource_files", ["exercise_id"], name: "index_exercises_resource_files_on_exercise_id"
  add_index "exercises_resource_files", ["resource_file_id"], name: "index_exercises_resource_files_on_resource_file_id"

  create_table "exercises_tags", force: true do |t|
    t.integer "exercise_id", null: false
    t.integer "tag_id",      null: false
  end

  add_index "exercises_tags", ["exercise_id"], name: "index_exercises_tags_on_exercise_id"
  add_index "exercises_tags", ["tag_id"], name: "index_exercises_tags_on_tag_id"

  create_table "global_roles", force: true do |t|
    t.string  "name",                                          null: false
    t.boolean "can_manage_all_courses",        default: false, null: false
    t.boolean "can_edit_system_configuration", default: false, null: false
    t.boolean "builtin",                       default: false, null: false
  end

  create_table "identities", force: true do |t|
    t.integer  "user_id",    null: false
    t.string   "provider",   null: false
    t.string   "uid",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "identities", ["uid", "provider"], name: "index_identities_on_uid_and_provider"
  add_index "identities", ["user_id"], name: "index_identities_on_user_id"

  create_table "organizations", force: true do |t|
    t.string   "name",       null: false
    t.string   "url_part",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organizations", ["url_part"], name: "index_organizations_on_url_part"

  create_table "prompts", force: true do |t|
    t.integer  "exercise_id",       null: false
    t.integer  "language_id",       null: false
    t.text     "instruction",       null: false
    t.integer  "order",             null: false
    t.integer  "max_user_attempts", null: false
    t.integer  "attempts",          null: false
    t.float    "correct",           null: false
    t.text     "feedback"
    t.float    "difficulty",        null: false
    t.float    "discrimination",    null: false
    t.integer  "type",              null: false
    t.boolean  "allow_multiple"
    t.boolean  "is_scrambled"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "prompts", ["exercise_id"], name: "index_prompts_on_exercise_id"
  add_index "prompts", ["language_id"], name: "index_prompts_on_language_id"

  create_table "resource_files", force: true do |t|
    t.string   "filename"
    t.string   "token",                     null: false
    t.integer  "user_id",                   null: false
    t.boolean  "public",     default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resource_files", ["token"], name: "index_resource_files_on_token"
  add_index "resource_files", ["user_id"], name: "index_resource_files_on_user_id"

  create_table "signups", force: true do |t|
    t.string   "first_name"
    t.string   "last_name_name"
    t.string   "email"
    t.string   "institution"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stems", force: true do |t|
    t.text     "preamble"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tag_user_scores", force: true do |t|
    t.integer  "user_id",                         null: false
    t.integer  "tag_id",                          null: false
    t.integer  "experience",          default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "completed_exercises", default: 0
  end

  add_index "tag_user_scores", ["tag_id"], name: "index_tag_user_scores_on_tag_id"
  add_index "tag_user_scores", ["user_id"], name: "index_tag_user_scores_on_user_id"

  create_table "tags", force: true do |t|
    t.string   "tag_name",                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tagtype",          default: 0
    t.integer  "total_exercises",  default: 0
    t.integer  "total_experience", default: 0
  end

  create_table "tags_workouts", force: true do |t|
    t.integer "tag_id",     null: false
    t.integer "workout_id", null: false
  end

  add_index "tags_workouts", ["tag_id"], name: "index_tags_workouts_on_tag_id"
  add_index "tags_workouts", ["workout_id"], name: "index_tags_workouts_on_workout_id"

  create_table "terms", force: true do |t|
    t.integer  "season",     null: false
    t.date     "starts_on",  null: false
    t.date     "ends_on",    null: false
    t.integer  "year",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "terms", ["year", "season"], name: "index_terms_on_year_and_season"

  create_table "test_case_results", force: true do |t|
    t.integer  "test_case_id",       null: false
    t.integer  "user_id",            null: false
    t.text     "execution_feedback"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "pass",               null: false
  end

  add_index "test_case_results", ["test_case_id"], name: "index_test_case_results_on_test_case_id"
  add_index "test_case_results", ["user_id"], name: "index_test_case_results_on_user_id"

  create_table "test_cases", force: true do |t|
    t.string   "test_script"
    t.text     "negative_feedback",  null: false
    t.float    "weight",             null: false
    t.text     "description"
    t.string   "input",              null: false
    t.string   "expected_output",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "coding_question_id", null: false
  end

  add_index "test_cases", ["coding_question_id"], name: "index_test_cases_on_coding_question_id"

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "global_role_id",                      null: false
    t.string   "avatar"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["global_role_id"], name: "index_users_on_global_role_id"
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "variation_groups", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workout_offerings", force: true do |t|
    t.integer  "course_offering_id", null: false
    t.integer  "workout_id",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "opening_date"
    t.date     "soft_deadline"
    t.date     "hard_deadline"
  end

  add_index "workout_offerings", ["course_offering_id"], name: "index_workout_offerings_on_course_offering_id"
  add_index "workout_offerings", ["workout_id"], name: "index_workout_offerings_on_workout_id"

  create_table "workout_scores", force: true do |t|
    t.integer  "workout_id",          null: false
    t.integer  "user_id",             null: false
    t.float    "score"
    t.boolean  "completed"
    t.datetime "completed_at"
    t.datetime "last_attempted_at"
    t.integer  "exercises_completed"
    t.integer  "exercises_remaining"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workout_scores", ["user_id"], name: "index_workout_scores_on_user_id"
  add_index "workout_scores", ["workout_id"], name: "index_workout_scores_on_workout_id"

  create_table "workouts", force: true do |t|
    t.string   "name",                              null: false
    t.boolean  "scrambled",         default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "target_group"
    t.integer  "points_multiplier"
    t.integer  "creator_id"
  end

end
