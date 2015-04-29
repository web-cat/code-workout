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

class CourseBaseExercise < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :course, inverse_of: :course_base_exercises
  belongs_to :base_exercise, inverse_of: :course_base_exercises


  #~ Validation ...............................................................

  validates :course, presence: true
  validates :base_exercise, presence: true

end
