# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :test_case do
    test_script "MyString"
    negative_feedback "MyText"
    weight 1.5
    description "MyText"
    input "MyString"
    expected_output "MyString"
  end
end
