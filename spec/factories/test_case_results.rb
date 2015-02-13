# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :test_case_result do
    test_case_id 1
    user_id 1
    score ""
    execution_feedback "MyText"
  end
end
