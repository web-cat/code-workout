# == Schema Information
#
# Table name: workout_scores
#
#  id                      :integer          not null, primary key
#  completed               :boolean
#  completed_at            :datetime
#  exercises_completed     :integer
#  exercises_remaining     :integer
#  last_attempted_at       :datetime
#  lis_outcome_service_url :string(255)
#  lis_result_sourcedid    :string(255)
#  score                   :float(24)
#  created_at              :datetime
#  updated_at              :datetime
#  lti_workout_id          :integer
#  user_id                 :integer          not null
#  workout_id              :integer          not null
#  workout_offering_id     :integer
#
# Indexes
#
#  index_workout_scores_on_lti_workout_id  (lti_workout_id)
#  index_workout_scores_on_user_id         (user_id)
#  index_workout_scores_on_workout_id      (workout_id)
#  workout_scores_workout_offering_id_fk   (workout_offering_id)
#
# Foreign Keys
#
#  fk_rails_...                           (lti_workout_id => lti_workouts.id)
#  workout_scores_user_id_fk              (user_id => users.id)
#  workout_scores_workout_id_fk           (workout_id => workouts.id)
#  workout_scores_workout_offering_id_fk  (workout_offering_id => workout_offerings.id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :workout_score do
    score { "" }
    completed { false }
    started_at { "2015-01-17 14:08:55" }
    completed_at { "2015-01-17 14:08:55" }
    last_attempted_at { "2015-01-17 14:08:55" }
    exercises_completed { 1 }
    exercises_remaining { 1 }
  end
end
