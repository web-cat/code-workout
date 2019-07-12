class LtiWorkout < ActiveRecord::Base
  belongs_to :workout
  belongs_to :lms_instance
  has_many :workout_scores
end
