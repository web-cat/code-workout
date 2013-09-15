# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :course_enrollment do
    user ""
    course_offering ""
    course_role ""
  end
end
