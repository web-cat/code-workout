FactoryBot.define do
  factory :exercise_pool_item do
    association :exercise_pool
    association :exercise, factory: :coding_exercise
    position { 1 }
  end
end
