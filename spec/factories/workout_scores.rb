# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :workout_score do
    score ""
    completed false
    started_at "2015-01-17 14:08:55"
    completed_at "2015-01-17 14:08:55"
    last_attempted_at "2015-01-17 14:08:55"
    exercises_completed 1
    exercises_remaining 1
  end
end
