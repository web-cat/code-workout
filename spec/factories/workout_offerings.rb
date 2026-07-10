# == Schema Information
#
# Table name: workout_offerings
#
#  id                       :bigint           not null, primary key
#  attempt_limit            :integer
#  hard_deadline            :datetime
#  lms_assignment_url       :string(255)
#  most_recent              :boolean          default(TRUE)
#  opening_date             :datetime
#  published                :boolean          default(TRUE), not null
#  soft_deadline            :datetime
#  time_limit               :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  continue_from_workout_id :bigint
#  course_offering_id       :bigint           not null
#  lms_assignment_id        :string(255)
#  workout_id               :bigint           not null
#  workout_policy_id        :bigint
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
#  fk_rails_...                                   (continue_from_workout_id => workout_offerings.id)
#  fk_rails_...                                   (course_offering_id => course_offerings.id)
#  fk_rails_...                                   (workout_id => workouts.id)
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
