# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lti_workout do
    workout nil
    lms_instance nil
    lms_assignment_id "MyString"
  end
end
