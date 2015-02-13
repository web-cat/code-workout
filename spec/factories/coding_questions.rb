# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :coding_question do
    base_class "MyString"
    wrapper_code "MyText"
    test_script "MyText"
  end
end
