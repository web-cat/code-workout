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

ActiveRecord::Schema.define(version: 20141019134233) do

  create_table "attempts", force: true do |t|
    t.integer  "user_id",           null: false
    t.integer  "exercise_id",       null: false
    t.datetime "submit_time",       null: false
    t.integer  "submit_num",        null: false
    t.text     "answer"
    t.float    "score"
    t.integer  "experience_earned"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attempts", ["exercise_id"], name: "index_attempts_on_exercise_id"
  add_index "attempts", ["user_id"], name: "index_attempts_on_user_id"

  create_table "choices", force: true do |t|
    t.integer  "exercise_id", null: false
    t.string   "answer"
    t.integer  "order"
    t.text     "feedback"
    t.float    "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "choices", ["exercise_id"], name: "index_choices_on_exercise_id"

  create_table "course_enrollments", force: true do |t|
    t.integer "user_id"
    t.integer "course_offering_id"
    t.integer "course_role_id"
  end

  add_index "course_enrollments", ["course_offering_id"], name: "index_course_enrollments_on_course_offering_id"
  add_index "course_enrollments", ["course_role_id"], name: "index_course_enrollments_on_course_role_id"
  add_index "course_enrollments", ["user_id", "course_offering_id"], name: "index_course_enrollments_on_user_id_and_course_offering_id", unique: true
  add_index "course_enrollments", ["user_id"], name: "index_course_enrollments_on_user_id"

  create_table "course_offerings", force: true do |t|
    t.integer  "course_id",               null: false
    t.integer  "term_id",                 null: false
    t.string   "name",                    null: false
    t.string   "label"
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
  end

  add_index "courses", ["organization_id"], name: "index_courses_on_organization_id"
  add_index "courses", ["url_part"], name: "index_courses_on_url_part", unique: true

  create_table "exercises", force: true do |t|
    t.integer  "user_id",            null: false
    t.integer  "stem_id"
    t.string   "title"
    t.text     "question",           null: false
    t.text     "feedback"
    t.boolean  "is_public",          null: false
    t.integer  "priority",           null: false
    t.integer  "count_attempts",     null: false
    t.float    "count_correct",      null: false
    t.float    "difficulty",         null: false
    t.float    "discrimination",     null: false
    t.integer  "question_type",      null: false
    t.boolean  "mcq_allow_multiple"
    t.boolean  "mcq_is_scrambled"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "experience"
    t.text     "starter_code"
  end

  add_index "exercises", ["stem_id"], name: "index_exercises_on_stem_id"
  add_index "exercises", ["user_id"], name: "index_exercises_on_user_id"

  create_table "exercises_resource_files", id: false, force: true do |t|
    t.integer "exercise_id",      null: false
    t.integer "resource_file_id", null: false
  end

  create_table "exercises_tags", id: false, force: true do |t|
    t.integer "exercise_id"
    t.integer "tag_id"
  end

  add_index "exercises_tags", ["exercise_id", "tag_id"], name: "index_exercises_tags_on_exercise_id_and_tag_id", unique: true

  create_table "exercises_workouts", force: true do |t|
    t.integer  "workout_id",  null: false
    t.integer  "exercise_id", null: false
    t.integer  "points"
    t.integer  "order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "exercises_workouts", ["exercise_id"], name: "index_exercises_workouts_on_exercise_id"
  add_index "exercises_workouts", ["workout_id"], name: "index_exercises_workouts_on_workout_id"

  create_table "global_roles", force: true do |t|
    t.string  "name",                                          null: false
    t.boolean "can_manage_all_courses",        default: false, null: false
    t.boolean "can_edit_system_configuration", default: false, null: false
    t.boolean "builtin",                       default: false, null: false
  end

  create_table "identities", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "identities", ["user_id"], name: "index_identities_on_user_id"

  create_table "organizations", force: true do |t|
    t.string   "display_name", null: false
    t.string   "url_part",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organizations", ["display_name"], name: "index_organizations_on_display_name", unique: true
  add_index "organizations", ["url_part"], name: "index_organizations_on_url_part", unique: true

  create_table "prompts", force: true do |t|
    t.integer  "exercise_id",       null: false
    t.integer  "language_id",       null: false
    t.text     "instruction",       null: false
    t.integer  "order",             null: false
    t.integer  "max_user_attempts"
    t.integer  "attempts"
    t.float    "correct"
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
    t.string   "token"
    t.integer  "user_id"
    t.boolean  "public",     default: true
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
    t.integer "tag_id"
    t.integer "workout_id"
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

  add_index "terms", ["starts_on"], name: "index_terms_on_starts_on"

  create_table "test_cases", force: true do |t|
    t.string   "test_script", null: false
    t.integer  "exercise_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "test_cases", ["exercise_id"], name: "index_test_cases_on_exercise_id"

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
    t.integer  "global_role_id"
    t.string   "name"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["global_role_id"], name: "index_users_on_global_role_id"
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "workouts", force: true do |t|
    t.string   "name",                       null: false
    t.boolean  "scrambled",  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end