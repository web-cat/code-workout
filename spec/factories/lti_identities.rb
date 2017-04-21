# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lti_identity do
    lti_user_id "MyString"
    user nil
    lms_instance nil
  end
end
