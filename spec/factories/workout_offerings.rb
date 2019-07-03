# == Schema Information
#
# Table name: workout_offerings
#
#  id                       :integer          not null, primary key
#  course_offering_id       :integer          not null
#  workout_id               :integer          not null
#  created_at               :datetime
#  updated_at               :datetime
#  opening_date             :datetime
#  soft_deadline            :datetime
#  hard_deadline            :datetime
#  published                :boolean          default(TRUE), not null
#  time_limit               :integer
#  workout_policy_id        :integer
#  continue_from_workout_id :integer
#  lms_assignment_id        :string(255)
#  most_recent              :boolean          default(TRUE)
#  lms_assignment_url       :string(255)
#  attempt_limit            :integer
#
# Indexes
#
#  index_workout_offerings_on_course_offering_id  (course_offering_id)
#  index_workout_offerings_on_lms_assignment_id   (lms_assignment_id)
#  index_workout_offerings_on_workout_id          (workout_id)
#  index_workout_offerings_on_workout_policy_id   (workout_policy_id)
#  workout_offerings_continue_from_workout_id_fk  (continue_from_workout_id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :workout_offering do
    course_offering_id { 1 }
    workout_id { 1 }
    opening_date { "#{Date.today.year}-01-01 14:08:55" }
    soft_deadline { "#{Date.today.year}-12-30 14:08:55" }
    hard_deadline { "#{Date.today.year}-12-30 14:08:55" }
    published { true }
  end
end
