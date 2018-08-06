class VisualizationLogging < ActiveRecord::Base
  belongs_to :user
  belongs_to :exercise
  belongs_to :workout
  belongs_to :workout_offering
end
