# == Schema Information
#
# Table name: course_exercises
#
#  id          :integer          not null, primary key
#  course_id   :integer
#  exercise_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class CourseExercise < ActiveRecord::Base
  belongs_to :course
  belongs_to :exercise
end
