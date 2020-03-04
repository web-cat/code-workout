# == Schema Information
#
# Table name: attempts
#
#  id                  :integer          not null, primary key
#  user_id             :integer          not null
#  exercise_version_id :integer          not null
#  submit_time         :datetime         not null
#  submit_num          :integer          not null
#  score               :float(24)        default(0.0)
#  experience_earned   :integer
#  created_at          :datetime
#  updated_at          :datetime
#  workout_score_id    :integer
#  active_score_id     :integer
#  feedback_ready      :boolean
#  time_taken          :decimal(10, )
#  feedback_timeout    :decimal(10, )
#  worker_time         :decimal(10, )
#
# Indexes
#
#  index_attempts_on_active_score_id      (active_score_id)
#  index_attempts_on_exercise_version_id  (exercise_version_id)
#  index_attempts_on_user_id              (user_id)
#  index_attempts_on_workout_score_id     (workout_score_id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :attempt do
    user { 1 }
    exercise { 1 }
    submit_time { "2013-10-02 22:53:14" }
    submit_num { 1 }
    answer { "2" }
    score { 0 }
    experience_earned { 5 }
  end
end
