# == Schema Information
#
# Table name: lti_workouts
#
#  id                :integer          not null, primary key
#  workout_id        :integer
#  lms_assignment_id :string(255)      default(""), not null
#  created_at        :datetime
#  updated_at        :datetime
#  lms_instance_id   :integer
#
# Indexes
#
#  index_lti_workouts_on_lms_instance_id  (lms_instance_id)
#  index_lti_workouts_on_workout_id       (workout_id)
#

class LtiWorkout < ActiveRecord::Base
  belongs_to :workout
  belongs_to :lms_instance
  has_many :workout_scores
end
