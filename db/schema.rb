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

ActiveRecord::Schema.define(version: 20170920191837) do

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   default: "", null: false
    t.string   "resource_type", default: "", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "attempts", force: true do |t|
    t.integer  "user_id",                                      null: false
    t.integer  "exercise_version_id",                          null: false
    t.datetime "submit_time",                                  null: false
    t.integer  "submit_num",                                   null: false
    t.float    "score",               limit: 24, default: 0.0
    t.integer  "experience_earned"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "workout_score_id"
    t.integer  "active_score_id"
    t.boolean  "feedback_ready"
  end

  add_index "attempts", ["active_score_id"], name: "index_attempts_on_active_score_id", using: :btree
  add_index "attempts", ["exercise_version_id"], name: "index_attempts_on_exercise_version_id", using: :btree
  add_index "attempts", ["user_id"], name: "index_attempts_on_user_id", using: :btree
  add_index "attempts", ["workout_score_id"], name: "index_attempts_on_workout_score_id", using: :btree

  create_table "attempts_tag_user_scores", id: false, force: true do |t|
    t.integer "attempt_id"
    t.integer "tag_user_score_id"
  end

  add_index "attempts_tag_user_scores", ["attempt_id", "tag_user_score_id"], name: "attempts_tag_user_scores_idx", unique: true, using: :btree
  add_index "attempts_tag_user_scores", ["tag_user_score_id"], name: "attempts_tag_user_scores_tag_user_score_id_fk", using: :btree

  create_table "choices", force: true do |t|
    t.integer  "multiple_choice_prompt_id",            null: false
    t.integer  "position",                             null: false
    t.text     "feedback"
    t.float    "value",                     limit: 24, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "answer",                               null: false
  end

  add_index "choices", ["multiple_choice_prompt_id"], name: "index_choices_on_multiple_choice_prompt_id", using: :btree

  create_table "choices_multiple_choice_prompt_answers", id: false, force: true do |t|
    t.integer "choice_id"
    t.integer "multiple_choice_prompt_answer_id"
  end

  add_index "choices_multiple_choice_prompt_answers", ["choice_id", "multiple_choice_prompt_answer_id"], name: "choices_multiple_choice_prompt_answers_idx", unique: true, using: :btree
  add_index "choices_multiple_choice_prompt_answers", ["multiple_choice_prompt_answer_id"], name: "choices_MC_prompt_answers_MC_prompt_answer_id_fk", using: :btree

  create_table "coding_prompt_answers", force: true do |t|
    t.text "answer"
    t.text "error"
  end

  create_table "coding_prompts", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "class_name"
    t.text     "wrapper_code",                  null: false
    t.text     "test_script",                   null: false
    t.string   "method_name"
    t.text     "starter_code"
    t.boolean  "hide_examples", default: false, null: false
  end

  create_table "course_enrollments", force: true do |t|
    t.integer "user_id",            null: false
    t.integer "course_offering_id", null: false
    t.integer "course_role_id",     null: false
  end

  add_index "course_enrollments", ["course_offering_id"], name: "index_course_enrollments_on_course_offering_id", using: :btree
  add_index "course_enrollments", ["course_role_id"], name: "index_course_enrollments_on_course_role_id", using: :btree
  add_index "course_enrollments", ["user_id", "course_offering_id"], name: "index_course_enrollments_on_user_id_and_course_offering_id", unique: true, using: :btree
  add_index "course_enrollments", ["user_id"], name: "index_course_enrollments_on_user_id", using: :btree

  create_table "course_exercises", force: true do |t|
    t.integer  "course_id",   null: false
    t.integer  "exercise_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "course_exercises", ["course_id"], name: "course_exercises_course_id_fk", using: :btree
  add_index "course_exercises", ["exercise_id"], name: "course_exercises_exercise_id_fk", using: :btree

  create_table "course_offerings", force: true do |t|
    t.integer  "course_id",                            null: false
    t.integer  "term_id",                              null: false
    t.string   "label",                   default: "", null: false
    t.string   "url"
    t.boolean  "self_enrollment_allowed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "cutoff_date"
    t.integer  "lms_instance_id"
  end

  add_index "course_offerings", ["course_id"], name: "index_course_offerings_on_course_id", using: :btree
  add_index "course_offerings", ["lms_instance_id"], name: "index_course_offerings_on_lms_instance_id", using: :btree
  add_index "course_offerings", ["term_id"], name: "index_course_offerings_on_term_id", using: :btree

  create_table "course_roles", force: true do |t|
    t.string  "name",                       default: "",    null: false
    t.boolean "can_manage_course",          default: false, null: false
    t.boolean "can_manage_assignments",     default: false, null: false
    t.boolean "can_grade_submissions",      default: false, null: false
    t.boolean "can_view_other_submissions", default: false, null: false
    t.boolean "builtin",                    default: false, null: false
  end

  create_table "courses", force: true do |t|
    t.string   "name",            default: "",    null: false
    t.string   "number",          default: "",    null: false
    t.integer  "organization_id",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.string   "slug",            default: "",    null: false
    t.integer  "user_group_id"
    t.boolean  "is_hidden",       default: false
  end

  add_index "courses", ["organization_id"], name: "index_courses_on_organization_id", using: :btree
  add_index "courses", ["slug"], name: "index_courses_on_slug", using: :btree
  add_index "courses", ["user_group_id"], name: "index_courses_on_user_group_id", using: :btree

  create_table "errors", force: true do |t|
    t.string   "usable_type"
    t.integer  "usable_id"
    t.string   "class_name"
    t.text     "message"
    t.text     "trace"
    t.text     "target_url"
    t.text     "referer_url"
    t.text     "params"
    t.text     "user_agent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "errors", ["class_name"], name: "index_errors_on_class_name", using: :btree
  add_index "errors", ["created_at"], name: "index_errors_on_created_at", using: :btree

  create_table "exercise_collections", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "user_group_id"
    t.integer  "license_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "course_offering_id"
  end

  add_index "exercise_collections", ["course_offering_id"], name: "index_exercise_collections_on_course_offering_id", using: :btree
  add_index "exercise_collections", ["license_id"], name: "index_exercise_collections_on_license_id", using: :btree
  add_index "exercise_collections", ["user_group_id"], name: "index_exercise_collections_on_user_group_id", using: :btree
  add_index "exercise_collections", ["user_id"], name: "index_exercise_collections_on_user_id", using: :btree

  create_table "exercise_families", force: true do |t|
    t.string   "name",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exercise_owners", force: true do |t|
    t.integer "exercise_id", null: false
    t.integer "owner_id",    null: false
  end

  add_index "exercise_owners", ["exercise_id", "owner_id"], name: "index_exercise_owners_on_exercise_id_and_owner_id", unique: true, using: :btree
  add_index "exercise_owners", ["owner_id"], name: "exercise_owners_owner_id_fk", using: :btree

  create_table "exercise_versions", force: true do |t|
    t.integer  "stem_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "exercise_id",                          null: false
    t.integer  "version",                              null: false
    t.integer  "creator_id"
    t.integer  "irt_data_id"
    t.text     "text_representation", limit: 16777215
  end

  add_index "exercise_versions", ["creator_id"], name: "exercise_versions_creator_id_fk", using: :btree
  add_index "exercise_versions", ["exercise_id"], name: "index_exercise_versions_on_exercise_id", using: :btree
  add_index "exercise_versions", ["irt_data_id"], name: "exercise_versions_irt_data_id_fk", using: :btree
  add_index "exercise_versions", ["stem_id"], name: "index_exercise_versions_on_stem_id", using: :btree

  create_table "exercise_versions_resource_files", id: false, force: true do |t|
    t.integer "exercise_version_id", null: false
    t.integer "resource_file_id",    null: false
  end

  add_index "exercise_versions_resource_files", ["exercise_version_id"], name: "index_exercise_versions_resource_files_on_exercise_version_id", using: :btree
  add_index "exercise_versions_resource_files", ["resource_file_id"], name: "index_exercise_versions_resource_files_on_resource_file_id", using: :btree

  create_table "exercise_workouts", force: true do |t|
    t.integer  "exercise_id",                          null: false
    t.integer  "workout_id",                           null: false
    t.integer  "position",                             null: false
    t.float    "points",      limit: 24, default: 1.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "exercise_workouts", ["exercise_id"], name: "exercise_workouts_exercise_id_fk", using: :btree
  add_index "exercise_workouts", ["workout_id"], name: "exercise_workouts_workout_id_fk", using: :btree

  create_table "exercises", force: true do |t|
    t.integer  "question_type",                          null: false
    t.integer  "current_version_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "versions"
    t.integer  "exercise_family_id"
    t.string   "name"
    t.boolean  "is_public",              default: false, null: false
    t.integer  "experience",                             null: false
    t.integer  "irt_data_id"
    t.string   "external_id"
    t.integer  "exercise_collection_id"
  end

  add_index "exercises", ["current_version_id"], name: "index_exercises_on_current_version_id", using: :btree
  add_index "exercises", ["exercise_collection_id"], name: "index_exercises_on_exercise_collection_id", using: :btree
  add_index "exercises", ["exercise_family_id"], name: "index_exercises_on_exercise_family_id", using: :btree
  add_index "exercises", ["external_id"], name: "index_exercises_on_external_id", unique: true, using: :btree
  add_index "exercises", ["irt_data_id"], name: "exercises_irt_data_id_fk", using: :btree
  add_index "exercises", ["is_public"], name: "index_exercises_on_is_public", using: :btree

  create_table "friendly_id_slugs", force: true do |t|
    t.string   "slug",                      default: "", null: false
    t.integer  "sluggable_id",                           null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "global_roles", force: true do |t|
    t.string  "name",                          default: "",    null: false
    t.boolean "can_manage_all_courses",        default: false, null: false
    t.boolean "can_edit_system_configuration", default: false, null: false
    t.boolean "builtin",                       default: false, null: false
  end

  create_table "group_access_requests", force: true do |t|
    t.integer  "user_id"
    t.integer  "user_group_id"
    t.boolean  "pending",       default: true
    t.boolean  "decision"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_access_requests", ["user_group_id"], name: "index_group_access_requests_on_user_group_id", using: :btree
  add_index "group_access_requests", ["user_id"], name: "index_group_access_requests_on_user_id", using: :btree

  create_table "identities", force: true do |t|
    t.integer  "user_id",                 null: false
    t.string   "provider",   default: "", null: false
    t.string   "uid",        default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "identities", ["uid", "provider"], name: "index_identities_on_uid_and_provider", using: :btree
  add_index "identities", ["user_id"], name: "index_identities_on_user_id", using: :btree

  create_table "irt_data", force: true do |t|
    t.integer "attempt_count",             null: false
    t.float   "sum_of_scores",  limit: 24, null: false
    t.float   "difficulty",     limit: 24, null: false
    t.float   "discrimination", limit: 24, null: false
  end

  create_table "license_policies", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "can_fork"
    t.boolean  "is_public"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "licenses", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "url"
    t.integer  "license_policy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "licenses", ["license_policy_id"], name: "index_licenses_on_license_policy_id", using: :btree

  create_table "lms_instances", force: true do |t|
    t.string   "consumer_key"
    t.string   "consumer_secret"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
    t.integer  "lms_type_id"
    t.integer  "organization_id"
  end

  add_index "lms_instances", ["lms_type_id"], name: "lms_instances_lms_type_id_fk", using: :btree
  add_index "lms_instances", ["organization_id"], name: "index_lms_instances_on_organization_id", using: :btree
  add_index "lms_instances", ["url"], name: "index_lms_instances_on_url", unique: true, using: :btree

  create_table "lms_types", force: true do |t|
    t.string   "name",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lms_types", ["name"], name: "index_lms_types_on_name", unique: true, using: :btree

  create_table "lti_identities", force: true do |t|
    t.string   "lti_user_id"
    t.integer  "user_id"
    t.integer  "lms_instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lti_identities", ["lms_instance_id"], name: "index_lti_identities_on_lms_instance_id", using: :btree
  add_index "lti_identities", ["user_id"], name: "index_lti_identities_on_user_id", using: :btree

  create_table "memberships", force: true do |t|
    t.integer  "user_id"
    t.integer  "user_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "multiple_choice_prompt_answers", force: true do |t|
  end

  create_table "multiple_choice_prompts", force: true do |t|
    t.boolean "allow_multiple", default: false, null: false
    t.boolean "is_scrambled",   default: true,  null: false
  end

  create_table "organizations", force: true do |t|
    t.string   "name",         default: "",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "abbreviation"
    t.string   "slug",         default: "",    null: false
    t.boolean  "is_hidden",    default: false
  end

  add_index "organizations", ["slug"], name: "index_organizations_on_slug", unique: true, using: :btree

  create_table "prompt_answers", force: true do |t|
    t.integer "attempt_id"
    t.integer "prompt_id"
    t.integer "actable_id"
    t.string  "actable_type"
  end

  add_index "prompt_answers", ["actable_id"], name: "index_prompt_answers_on_actable_id", using: :btree
  add_index "prompt_answers", ["attempt_id", "prompt_id"], name: "index_prompt_answers_on_attempt_id_and_prompt_id", unique: true, using: :btree
  add_index "prompt_answers", ["attempt_id"], name: "index_prompt_answers_on_attempt_id", using: :btree
  add_index "prompt_answers", ["prompt_id"], name: "index_prompt_answers_on_prompt_id", using: :btree

  create_table "prompts", force: true do |t|
    t.integer  "exercise_version_id", null: false
    t.text     "question",            null: false
    t.integer  "position",            null: false
    t.text     "feedback"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "actable_id"
    t.string   "actable_type"
    t.integer  "irt_data_id"
  end

  add_index "prompts", ["actable_id"], name: "index_prompts_on_actable_id", using: :btree
  add_index "prompts", ["exercise_version_id"], name: "index_prompts_on_exercise_version_id", using: :btree
  add_index "prompts", ["irt_data_id"], name: "prompts_irt_data_id_fk", using: :btree

  create_table "resource_files", force: true do |t|
    t.string   "filename"
    t.string   "token",      default: "",   null: false
    t.integer  "user_id",                   null: false
    t.boolean  "public",     default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resource_files", ["token"], name: "index_resource_files_on_token", using: :btree
  add_index "resource_files", ["user_id"], name: "index_resource_files_on_user_id", using: :btree

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

  create_table "student_extensions", force: true do |t|
    t.integer  "user_id"
    t.integer  "workout_offering_id"
    t.datetime "soft_deadline"
    t.datetime "hard_deadline"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "time_limit"
    t.datetime "opening_date"
  end

  add_index "student_extensions", ["user_id"], name: "index_student_extensions_on_user_id", using: :btree
  add_index "student_extensions", ["workout_offering_id"], name: "index_student_extensions_on_workout_offering_id", using: :btree

  create_table "tag_user_scores", force: true do |t|
    t.integer  "user_id",                         null: false
    t.integer  "experience",          default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "completed_exercises", default: 0
  end

  add_index "tag_user_scores", ["user_id"], name: "index_tag_user_scores_on_user_id", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "terms", force: true do |t|
    t.integer  "season",                  null: false
    t.date     "starts_on",               null: false
    t.date     "ends_on",                 null: false
    t.integer  "year",                    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",       default: "", null: false
  end

  add_index "terms", ["slug"], name: "index_terms_on_slug", unique: true, using: :btree
  add_index "terms", ["year", "season"], name: "index_terms_on_year_and_season", using: :btree

  create_table "test_case_results", force: true do |t|
    t.integer  "test_case_id",            null: false
    t.integer  "user_id",                 null: false
    t.text     "execution_feedback"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "pass",                    null: false
    t.integer  "coding_prompt_answer_id"
  end

  add_index "test_case_results", ["coding_prompt_answer_id"], name: "index_test_case_results_on_coding_prompt_answer_id", using: :btree
  add_index "test_case_results", ["test_case_id"], name: "index_test_case_results_on_test_case_id", using: :btree
  add_index "test_case_results", ["user_id"], name: "index_test_case_results_on_user_id", using: :btree

  create_table "test_cases", force: true do |t|
    t.text     "negative_feedback"
    t.float    "weight",            limit: 24,                 null: false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "coding_prompt_id",                             null: false
    t.text     "input",                                        null: false
    t.text     "expected_output",                              null: false
    t.boolean  "static",                       default: false, null: false
    t.boolean  "screening",                    default: false, null: false
    t.boolean  "example",                      default: false, null: false
    t.boolean  "hidden",                       default: false, null: false
  end

  add_index "test_cases", ["coding_prompt_id"], name: "index_test_cases_on_coding_prompt_id", using: :btree

  create_table "time_zones", force: true do |t|
    t.string   "name"
    t.string   "zone"
    t.string   "display_as"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_groups", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  create_table "users", force: true do |t|
    t.string   "email",                    default: "", null: false
    t.string   "encrypted_password",       default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",            default: 0,  null: false
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
    t.integer  "global_role_id",                        null: false
    t.string   "avatar"
    t.string   "slug",                     default: "", null: false
    t.integer  "current_workout_score_id"
    t.integer  "time_zone_id"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["current_workout_score_id"], name: "index_users_on_current_workout_score_id", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["global_role_id"], name: "index_users_on_global_role_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", unique: true, using: :btree
  add_index "users", ["time_zone_id"], name: "index_users_on_time_zone_id", using: :btree

  create_table "workout_offerings", force: true do |t|
    t.integer  "course_offering_id",                      null: false
    t.integer  "workout_id",                              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "opening_date"
    t.datetime "soft_deadline"
    t.datetime "hard_deadline"
    t.boolean  "published",                default: true, null: false
    t.integer  "time_limit"
    t.integer  "workout_policy_id"
    t.integer  "continue_from_workout_id"
    t.string   "lms_assignment_id"
    t.boolean  "most_recent",              default: true
    t.string   "lms_assignment_url"
  end

  add_index "workout_offerings", ["continue_from_workout_id"], name: "workout_offerings_continue_from_workout_id_fk", using: :btree
  add_index "workout_offerings", ["course_offering_id"], name: "index_workout_offerings_on_course_offering_id", using: :btree
  add_index "workout_offerings", ["lms_assignment_id"], name: "index_workout_offerings_on_lms_assignment_id", using: :btree
  add_index "workout_offerings", ["workout_id"], name: "index_workout_offerings_on_workout_id", using: :btree
  add_index "workout_offerings", ["workout_policy_id"], name: "index_workout_offerings_on_workout_policy_id", using: :btree

  create_table "workout_owners", force: true do |t|
    t.integer "workout_id", null: false
    t.integer "owner_id",   null: false
  end

  add_index "workout_owners", ["owner_id"], name: "workout_owners_owner_id_fk", using: :btree
  add_index "workout_owners", ["workout_id", "owner_id"], name: "index_workout_owners_on_workout_id_and_owner_id", unique: true, using: :btree

  create_table "workout_policies", force: true do |t|
    t.boolean  "hide_thumbnails_before_start"
    t.boolean  "hide_feedback_before_finish"
    t.boolean  "hide_compilation_feedback_before_finish"
    t.boolean  "no_review_before_close"
    t.boolean  "hide_feedback_in_review_before_close"
    t.boolean  "hide_thumbnails_in_review_before_close"
    t.boolean  "no_hints"
    t.boolean  "no_faq"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "invisible_before_review"
    t.string   "description"
  end

  create_table "workout_scores", force: true do |t|
    t.integer  "workout_id",                         null: false
    t.integer  "user_id",                            null: false
    t.float    "score",                   limit: 24
    t.boolean  "completed"
    t.datetime "completed_at"
    t.datetime "last_attempted_at"
    t.integer  "exercises_completed"
    t.integer  "exercises_remaining"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "workout_offering_id"
    t.string   "lis_outcome_service_url"
    t.string   "lis_result_sourcedid"
  end

  add_index "workout_scores", ["user_id"], name: "index_workout_scores_on_user_id", using: :btree
  add_index "workout_scores", ["workout_id"], name: "index_workout_scores_on_workout_id", using: :btree
  add_index "workout_scores", ["workout_offering_id"], name: "workout_scores_workout_offering_id_fk", using: :btree

  create_table "workouts", force: true do |t|
    t.string   "name",              default: "",    null: false
    t.boolean  "scrambled",         default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "points_multiplier"
    t.integer  "creator_id"
    t.string   "external_id"
    t.boolean  "is_public"
  end

  add_index "workouts", ["creator_id"], name: "workouts_creator_id_fk", using: :btree
  add_index "workouts", ["external_id"], name: "index_workouts_on_external_id", unique: true, using: :btree
  add_index "workouts", ["is_public"], name: "index_workouts_on_is_public", using: :btree

  add_foreign_key "attempts", "exercise_versions", name: "attempts_exercise_version_id_fk"
  add_foreign_key "attempts", "users", name: "attempts_user_id_fk"
  add_foreign_key "attempts", "workout_scores", name: "attempts_active_score_id_fk", column: "active_score_id"
  add_foreign_key "attempts", "workout_scores", name: "attempts_workout_score_id_fk"

  add_foreign_key "attempts_tag_user_scores", "attempts", name: "attempts_tag_user_scores_attempt_id_fk"
  add_foreign_key "attempts_tag_user_scores", "tag_user_scores", name: "attempts_tag_user_scores_tag_user_score_id_fk"

  add_foreign_key "choices", "multiple_choice_prompts", name: "choices_multiple_choice_prompt_id_fk"

  add_foreign_key "choices_multiple_choice_prompt_answers", "choices", name: "choices_multiple_choice_prompt_answers_choice_id_fk"
  add_foreign_key "choices_multiple_choice_prompt_answers", "multiple_choice_prompt_answers", name: "choices_MC_prompt_answers_MC_prompt_answer_id_fk"

  add_foreign_key "course_enrollments", "course_offerings", name: "course_enrollments_course_offering_id_fk"
  add_foreign_key "course_enrollments", "course_roles", name: "course_enrollments_course_role_id_fk"
  add_foreign_key "course_enrollments", "users", name: "course_enrollments_user_id_fk"

  add_foreign_key "course_exercises", "courses", name: "course_exercises_course_id_fk"
  add_foreign_key "course_exercises", "exercises", name: "course_exercises_exercise_id_fk"

  add_foreign_key "course_offerings", "courses", name: "course_offerings_course_id_fk"
  add_foreign_key "course_offerings", "terms", name: "course_offerings_term_id_fk"

  add_foreign_key "courses", "organizations", name: "courses_organization_id_fk"

  add_foreign_key "exercise_owners", "exercises", name: "exercise_owners_exercise_id_fk"
  add_foreign_key "exercise_owners", "users", name: "exercise_owners_owner_id_fk", column: "owner_id"

  add_foreign_key "exercise_versions", "exercises", name: "exercise_versions_exercise_id_fk"
  add_foreign_key "exercise_versions", "irt_data", name: "exercise_versions_irt_data_id_fk", column: "irt_data_id"
  add_foreign_key "exercise_versions", "stems", name: "exercise_versions_stem_id_fk"
  add_foreign_key "exercise_versions", "users", name: "exercise_versions_creator_id_fk", column: "creator_id"

  add_foreign_key "exercise_versions_resource_files", "exercise_versions", name: "exercise_versions_resource_files_exercise_version_id_fk"
  add_foreign_key "exercise_versions_resource_files", "resource_files", name: "exercise_versions_resource_files_resource_file_id_fk"

  add_foreign_key "exercise_workouts", "exercises", name: "exercise_workouts_exercise_id_fk"
  add_foreign_key "exercise_workouts", "workouts", name: "exercise_workouts_workout_id_fk"

  add_foreign_key "exercises", "exercise_families", name: "exercises_exercise_family_id_fk"
  add_foreign_key "exercises", "exercise_versions", name: "exercises_current_version_id_fk", column: "current_version_id"
  add_foreign_key "exercises", "irt_data", name: "exercises_irt_data_id_fk", column: "irt_data_id"

  add_foreign_key "identities", "users", name: "identities_user_id_fk"

  add_foreign_key "lms_instances", "lms_types", name: "lms_instances_lms_type_id_fk"

  add_foreign_key "prompt_answers", "attempts", name: "prompt_answers_attempt_id_fk"
  add_foreign_key "prompt_answers", "prompts", name: "prompt_answers_prompt_id_fk"

  add_foreign_key "prompts", "exercise_versions", name: "prompts_exercise_version_id_fk"
  add_foreign_key "prompts", "irt_data", name: "prompts_irt_data_id_fk", column: "irt_data_id"

  add_foreign_key "resource_files", "users", name: "resource_files_user_id_fk"

  add_foreign_key "student_extensions", "users", name: "student_extensions_user_id_fk"
  add_foreign_key "student_extensions", "workout_offerings", name: "student_extensions_workout_offering_id_fk"

  add_foreign_key "tag_user_scores", "users", name: "tag_user_scores_user_id_fk"

  add_foreign_key "test_case_results", "coding_prompt_answers", name: "test_case_results_coding_prompt_answer_id_fk"
  add_foreign_key "test_case_results", "test_cases", name: "test_case_results_test_case_id_fk"
  add_foreign_key "test_case_results", "users", name: "test_case_results_user_id_fk"

  add_foreign_key "test_cases", "coding_prompts", name: "test_cases_coding_prompt_id_fk"

  add_foreign_key "users", "global_roles", name: "users_global_role_id_fk"
  add_foreign_key "users", "time_zones", name: "users_time_zone_id_fk"
  add_foreign_key "users", "workout_scores", name: "users_current_workout_score_id_fk", column: "current_workout_score_id"

  add_foreign_key "workout_offerings", "course_offerings", name: "workout_offerings_course_offering_id_fk"
  add_foreign_key "workout_offerings", "workout_offerings", name: "workout_offerings_continue_from_workout_id_fk", column: "continue_from_workout_id"
  add_foreign_key "workout_offerings", "workout_policies", name: "workout_offerings_workout_policy_id_fk"
  add_foreign_key "workout_offerings", "workouts", name: "workout_offerings_workout_id_fk"

  add_foreign_key "workout_owners", "users", name: "workout_owners_owner_id_fk", column: "owner_id"
  add_foreign_key "workout_owners", "workouts", name: "workout_owners_workout_id_fk"

  add_foreign_key "workout_scores", "users", name: "workout_scores_user_id_fk"
  add_foreign_key "workout_scores", "workout_offerings", name: "workout_scores_workout_offering_id_fk"
  add_foreign_key "workout_scores", "workouts", name: "workout_scores_workout_id_fk"

  add_foreign_key "workouts", "users", name: "workouts_creator_id_fk", column: "creator_id"

end
