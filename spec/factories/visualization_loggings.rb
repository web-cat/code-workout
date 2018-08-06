# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :visualization_logging do
    user nil
    exercise nil
    workout nil
    workout_offering nil
  end
end
