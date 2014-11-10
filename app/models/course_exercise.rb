class CourseExercise < ActiveRecord::Base
  belongs_to :course
  belongs_to :exercise
end
