FactoryBot.define do
  factory :workout_score_exercise do
    association :workout_score
    association :exercise, factory: :coding_exercise
    association :exercise_pool
    position { 1 }
    points { 5.0 }
  end
end
