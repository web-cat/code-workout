# == Schema Information
#
# Table name: course_exercises
#
#  id          :integer          not null, primary key
#  course_id   :integer
#  exercise_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :course_exercise do
    course_id 1
    exercise_id 1
  end
end
