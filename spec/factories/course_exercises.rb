# == Schema Information
#
# Table name: course_exercises
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  course_id   :bigint           not null
#  exercise_id :bigint           not null
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
#  fk_rails_...                     (course_id => courses.id)
#  fk_rails_...                     (exercise_id => exercise_versions.id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :course_exercise do
    course_id { 1 }
    exercise_id { 1 }
  end
end
