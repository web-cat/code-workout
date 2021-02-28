# == Schema Information
#
# Table name: workout_offerings
#
#  id                       :integer          not null, primary key
#  attempt_limit            :integer
#  hard_deadline            :datetime
#  lms_assignment_url       :string(255)
#  most_recent              :boolean          default(TRUE)
#  opening_date             :datetime
#  published                :boolean          default(TRUE), not null
#  soft_deadline            :datetime
#  time_limit               :integer
#  created_at               :datetime
#  updated_at               :datetime
#  continue_from_workout_id :integer
#  course_offering_id       :integer          not null
#  lms_assignment_id        :string(255)
#  workout_id               :integer          not null
#  workout_policy_id        :integer
#
# Indexes
#
#  index_workout_offerings_on_course_offering_id  (course_offering_id)
#  index_workout_offerings_on_lms_assignment_id   (lms_assignment_id)
#  index_workout_offerings_on_workout_id          (workout_id)
#  index_workout_offerings_on_workout_policy_id   (workout_policy_id)
#  workout_offerings_continue_from_workout_id_fk  (continue_from_workout_id)
#
# Foreign Keys
#
#  workout_offerings_continue_from_workout_id_fk  (continue_from_workout_id => workout_offerings.id)
#  workout_offerings_course_offering_id_fk        (course_offering_id => course_offerings.id)
#  workout_offerings_workout_id_fk                (workout_id => workouts.id)
#  workout_offerings_workout_policy_id_fk         (workout_policy_id => workout_policies.id)
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
