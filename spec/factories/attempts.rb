# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :attempt do
    user 1
    exercise 1
    submit_time "2013-10-02 22:53:14"
    submit_num 1
    answer "2"
    score 0
    experience_earned 5
  end
end
