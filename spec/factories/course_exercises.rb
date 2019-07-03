# == Schema Information
#
# Table name: course_exercises
#
#  id          :integer          not null, primary key
#  course_id   :integer          not null
#  exercise_id :integer          not null
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  course_exercises_course_id_fk    (course_id)
#  course_exercises_exercise_id_fk  (exercise_id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :course_exercise do
    course_id { 1 }
    exercise_id { 1 }
  end
end
