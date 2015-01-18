# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :base_exercise do
    user_id 1
    question_type 1
    current_version 1
  end
end
