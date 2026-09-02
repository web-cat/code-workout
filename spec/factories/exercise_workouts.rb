# == Schema Information
#
# Table name: exercise_workouts
#
#  id          :bigint           not null, primary key
#  points      :float(24)        default(1.0)
#  position    :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  exercise_id :bigint           not null
#  workout_id  :bigint           not null
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
#  fk_rails_...                      (exercise_id => exercise_versions.id)
#  fk_rails_...                      (workout_id => workouts.id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :exercise_workout do
    association :exercise, factory: :coding_exercise
    association :workout
    points { 10 }
  end
end
