class WorkoutOffering < ActiveRecord::Base
  belongs_to :workout
  belongs_to :course_offering
end
