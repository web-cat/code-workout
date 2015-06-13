# == Schema Information
#
# Table name: workout_offerings
#
#  id                 :integer          not null, primary key
#  course_offering_id :integer          not null
#  workout_id         :integer          not null
#  created_at         :datetime
#  updated_at         :datetime
#  opening_date       :date
#  soft_deadline      :date
#  hard_deadline      :date
#
# Indexes
#
#  index_workout_offerings_on_course_offering_id  (course_offering_id)
#  index_workout_offerings_on_workout_id          (workout_id)
#


# =============================================================================
# Represents a many-to-many relationship between workouts and course
# offerings, where each instance of the relationship represents one
# "assignment" for one "section" of a course.  Workout offerings have
# due dates that control when the students in the corresponding course
# offering can take the workout (and thus, when they must complete it).
#
class WorkoutOffering < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :workout, inverse_of: :workout_offerings
  belongs_to :course_offering, inverse_of: :workout_offerings
  has_many :workout_scores, inverse_of: :workout_offering, dependent: :nullify


  scope :visible_to_students, -> { where{
    (published == true) &
    ((opening_date == nil) | (opening_date <= Time.now)) } }


  #~ Validation ...............................................................

  validates :course_offering, presence: true
  validates :workout, presence: true


  #~ Instance methods .........................................................

  # -------------------------------------------------------------
  def score_for(user)
    workout_scores.where(user: user).order('updated_at DESC').first
  end

end
