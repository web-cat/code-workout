# == Schema Information
#
# Table name: workout_offerings
#
#  id                 :integer          not null, primary key
#  course_offering_id :integer          not null
#  workout_id         :integer          not null
#  created_at         :datetime
#  updated_at         :datetime
#  opening_date       :datetime
#  soft_deadline      :datetime
#  hard_deadline      :datetime
#  published          :boolean          default(FALSE), not null
#  time_limit         :integer
#  workout_policy_id  :integer
#
# Indexes
#
#  index_workout_offerings_on_course_offering_id  (course_offering_id)
#  index_workout_offerings_on_workout_id          (workout_id)
#  index_workout_offerings_on_workout_policy_id   (workout_policy_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :workout_offering do
    course_offering_id 1
    workout_id 1
    published true
    opening_date DateTime.now
    soft_deadline 1.year.from_now
    hard_deadline 1.years.from_now
  end
end
