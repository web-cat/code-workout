# == Schema Information
#
# Table name: visualization_loggings
#
#  id                  :bigint           not null, primary key
#  ip_address          :string(255)
#  lti_launch          :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  exercise_id         :bigint
#  lms_instance_id     :bigint
#  user_id             :bigint
#  workout_id          :bigint
#  workout_offering_id :bigint
#  workout_score_id    :bigint
#
# Indexes
#
#  index_visualization_loggings_on_exercise_id          (exercise_id)
#  index_visualization_loggings_on_lms_instance_id      (lms_instance_id)
#  index_visualization_loggings_on_user_id              (user_id)
#  index_visualization_loggings_on_workout_id           (workout_id)
#  index_visualization_loggings_on_workout_offering_id  (workout_offering_id)
#  index_visualization_loggings_on_workout_score_id     (workout_score_id)
#

class VisualizationLogging < ApplicationRecord
  belongs_to :user
  belongs_to :exercise
  belongs_to :workout
  belongs_to :workout_offering
  belongs_to :workout_score, optional: true
end
