# == Schema Information
#
# Table name: course_exercises
#
#  id          :integer          not null, primary key
#  created_at  :datetime
#  updated_at  :datetime
#  course_id   :integer          not null
#  exercise_id :integer          not null
#
# Indexes
#
#  course_exercises_course_id_fk    (course_id)
#  course_exercises_exercise_id_fk  (exercise_id)
#
# Foreign Keys
#
#  course_exercises_course_id_fk    (course_id => courses.id)
#  course_exercises_exercise_id_fk  (exercise_id => exercises.id)
#

# =============================================================================
# Represents a many-to-many relationship between courses and exercises,
# capturing the notion of course-specific question banks.  I'm not sure
# If we really need many-to-many, though, since right now, exercises can
# only belong to one course?
#
class CourseExercise < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :course, inverse_of: :course_exercises
  belongs_to :exercise, inverse_of: :course_exercises


  #~ Validation ...............................................................

  validates :course, presence: true
  validates :exercise, presence: true

end
