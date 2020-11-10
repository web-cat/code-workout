# == Schema Information
#
# Table name: course_exercises
#
#  id          :integer          not null, primary key
#  created_at  :datetime
#  updated_at  :datetime
#  course_id   :integer          not null
#  exercise_id :integer          not null
#
# Indexes
#
#  course_exercises_course_id_fk    (course_id)
#  course_exercises_exercise_id_fk  (exercise_id)
#
# Foreign Keys
#
#  course_exercises_course_id_fk    (course_id => courses.id)
#  course_exercises_exercise_id_fk  (exercise_id => exercises.id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :course_exercise do
    course_id { 1 }
    exercise_id { 1 }
  end
end
