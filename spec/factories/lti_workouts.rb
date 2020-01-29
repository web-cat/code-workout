# == Schema Information
#
# Table name: lti_workouts
#
#  id                :integer          not null, primary key
#  workout_id        :integer
#  lms_assignment_id :string(255)      default(""), not null
#  created_at        :datetime
#  updated_at        :datetime
#  lms_instance_id   :integer
#
# Indexes
#
#  index_lti_workouts_on_lms_instance_id  (lms_instance_id)
#  index_lti_workouts_on_workout_id       (workout_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :lti_workout do
    workout { nil }
    lms_instance { nil }
    lms_assignment_id { "MyString" }
  end
end
