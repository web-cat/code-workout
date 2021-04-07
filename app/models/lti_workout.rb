# == Schema Information
#
# Table name: lti_workouts
#
#  id                :integer          not null, primary key
#  created_at        :datetime
#  updated_at        :datetime
#  lms_assignment_id :string(255)      not null
#  lms_instance_id   :integer
#  workout_id        :integer
#
# Indexes
#
#  index_lti_workouts_on_lms_instance_id  (lms_instance_id)
#  index_lti_workouts_on_workout_id       (workout_id)
#
# Foreign Keys
#
#  fk_rails_...  (lms_instance_id => lms_instances.id)
#

class LtiWorkout < ActiveRecord::Base
  belongs_to :workout
  belongs_to :lms_instance
  has_many :workout_scores
end
