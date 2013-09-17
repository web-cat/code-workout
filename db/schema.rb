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

ActiveRecord::Schema.define(version: 20130916142010) do

  create_table "choices", force: true do |t|
    t.integer  "prompt_id",  null: false
    t.string   "answer"
    t.integer  "order"
    t.text     "feedback"
    t.float    "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "choices", ["prompt_id"], name: "index_choices_on_prompt_id"

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

  create_table "exercises", force: true do |t|
    t.string   "title",      null: false
    t.text     "preamble"
    t.integer  "user",       null: false
    t.boolean  "is_public",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exercises_tags", force: true do |t|
    t.integer "exercise_id"
    t.integer "tag_id"
  end

  create_table "global_roles", force: true do |t|
    t.string  "name",                                          null: false
    t.boolean "can_manage_all_courses",        default: false, null: false
    t.boolean "can_edit_system_configuration", default: false, null: false
    t.boolean "builtin",                       default: false, null: false
  end

  create_table "languages", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organizations", force: true do |t|
    t.string   "display_name", null: false
    t.string   "url_part",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "tags", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "terms", force: true do |t|
    t.integer  "season",     null: false
    t.date     "starts_on",  null: false
    t.date     "ends_on",    null: false
    t.integer  "year",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
