# == Schema Information
#
# Table name: exercise_workouts
#
#  id          :integer          not null, primary key
#  points      :float(24)        default(1.0)
#  position    :integer          not null
#  created_at  :datetime
#  updated_at  :datetime
#  exercise_id :integer          not null
#  workout_id  :integer          not null
#
# Indexes
#
#  exercise_workouts_exercise_id_fk  (exercise_id)
#  exercise_workouts_workout_id_fk   (workout_id)
#
# Foreign Keys
#
#  exercise_workouts_exercise_id_fk  (exercise_id => exercises.id)
#  exercise_workouts_workout_id_fk   (workout_id => workouts.id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :exercise_workout do
    exercise_id { 1 }
    workout_id { 1 }
    points { 10 }
  end
end
