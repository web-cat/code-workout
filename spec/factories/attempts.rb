# == Schema Information
#
# Table name: attempts
#
#  id                :integer          not null, primary key
#  user_id           :integer          not null
#  exercise_id       :integer          not null
#  submit_time       :datetime         not null
#  submit_num        :integer          not null
#  answer            :text
#  score             :float
#  experience_earned :integer
#  created_at        :datetime
#  updated_at        :datetime
#
# Indexes
#
#  index_attempts_on_exercise_id  (exercise_id)
#  index_attempts_on_user_id      (user_id)
#

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
