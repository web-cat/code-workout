# == Schema Information
#
# Table name: lti_workouts
#
#  id                :bigint           not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  lms_assignment_id :string(255)      not null
#  lms_instance_id   :bigint
#  workout_id        :bigint
#
# Indexes
#
#  index_lti_workouts_on_lms_instance_id  (lms_instance_id)
#  index_lti_workouts_on_workout_id       (workout_id)
#
# Foreign Keys
#
#  fk_rails_...  (lms_instance_id => lms_instances.id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :lti_workout do
    workout { nil }
    lms_instance { nil }
    lms_assignment_id { "MyString" }
  end
end
