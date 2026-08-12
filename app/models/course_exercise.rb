# == Schema Information
#
# Table name: course_exercises
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  course_id   :bigint           not null
#  exercise_id :bigint           not null
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
#  fk_rails_...                     (course_id => courses.id)
#  fk_rails_...                     (exercise_id => exercise_versions.id)
#

# =============================================================================
# Represents a many-to-many relationship between courses and exercises,
# capturing the notion of course-specific question banks.  I'm not sure
# If we really need many-to-many, though, since right now, exercises can
# only belong to one course?
#
class CourseExercise < ApplicationRecord

  #~ Relationships ............................................................

  belongs_to :course, inverse_of: :course_exercises
  belongs_to :exercise, inverse_of: :course_exercises


  #~ Validation ...............................................................

  validates :course, presence: true
  validates :exercise, presence: true

end
