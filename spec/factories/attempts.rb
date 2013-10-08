# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :attempt do
    user nil
    exercise nil
    submit_time "2013-10-02 22:53:14"
    submit_num 1
    answer "MyText"
    score 1.5
    experience_earned 1
  end
end
