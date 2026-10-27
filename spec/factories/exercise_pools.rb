FactoryBot.define do
  factory :exercise_pool do
    association :workout
    name { 'Test Exercise Pool' }
    select_count { 1 }
    points { 5.0 }
  end
end
