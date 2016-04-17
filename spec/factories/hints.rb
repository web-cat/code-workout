# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :hint do
    exercise_version_id 1
    user_id 1
    body "MyString"
    curated false
  end
end
