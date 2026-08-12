# == Schema Information
#
# Table name: attempts
#
#  id                  :bigint           not null, primary key
#  experience_earned   :integer
#  feedback_ready      :boolean
#  feedback_timeout    :decimal(10, )
#  ip_address          :string(255)
#  lti_launch          :boolean          default(FALSE)
#  score               :float(24)        default(0.0)
#  submit_num          :integer          not null
#  submit_time         :datetime         not null
#  time_taken          :decimal(10, )
#  worker_time         :decimal(10, )
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  active_score_id     :bigint
#  exercise_version_id :bigint           not null
#  lms_instance_id     :bigint
#  user_id             :bigint           not null
#  workout_score_id    :bigint
#
# Indexes
#
#  idx_attempts_on_user_exercise_version           (user_id,exercise_version_id)
#  idx_attempts_on_workout_score_exercise_version  (workout_score_id,exercise_version_id)
#  index_attempts_on_active_score_id               (active_score_id)
#  index_attempts_on_exercise_version_id           (exercise_version_id)
#  index_attempts_on_lms_instance_id               (lms_instance_id)
#  index_attempts_on_user_id                       (user_id)
#  index_attempts_on_workout_score_id              (workout_score_id)
#
# Foreign Keys
#
#  attempts_active_score_id_fk      (active_score_id => workout_scores.id)
#  attempts_exercise_version_id_fk  (exercise_version_id => exercise_versions.id)
#  attempts_user_id_fk              (user_id => users.id)
#  attempts_workout_score_id_fk     (workout_score_id => workout_scores.id)
#  fk_rails_...                     (exercise_version_id => exercise_versions.id)
#  fk_rails_...                     (user_id => users.id)
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
