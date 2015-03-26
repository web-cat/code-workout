# == Schema Information
#
# Table name: course_exercises
#
#  id          :integer          not null, primary key
#  course_id   :integer          not null
#  exercise_id :integer          not null
#  created_at  :datetime
#  updated_at  :datetime
#

class CourseExercise < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :course, inverse_of: :course_exercises
  belongs_to :exercise, inverse_of: :course_exercises


  #~ Validation ...............................................................

  validates :course, presence: true
  validates :exercise, presence: true

end
