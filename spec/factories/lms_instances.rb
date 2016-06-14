# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lms_instance do
    consumer_key "MyString"
    consumer_secret "MyString"
  end
end
