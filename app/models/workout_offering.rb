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
  has_many :student_extensions
  has_many :users, through: :student_extensions

  scope :visible_to_students, -> { where{
    (published == true) &
    ((opening_date == nil) | (opening_date <= Time.now)) } }


  #~ Validation ...............................................................

  validates :course_offering, presence: true
  validates :workout, presence: true


  #~ Instance methods .........................................................

  # -----------------------------------------------------------------
  def score_for(user)
    workout_scores.where(user: user).order('updated_at DESC').first
  end
  
  # --------------------------------------------------------------------------------
  # Describes how 'far' is the workout offering from its hard and soft deadlines. 
  # 4 indicates that there is more than one day remaining to soft deadline
  # 1 indicates that it is past the hard deadline
  # nil indicates that there is no valid deadline
  # Else it will return the number of hours remaining to the soft deadline
  def current_deadline_distance
    current_time = Time.now.to_i

    if hard_deadline.nil?
      return nil
    end

    if hard_deadline.to_i < current_time
      return 1
    end

    if soft_deadline.to_i - current_time > 86400
      return 4
    end
    return (soft_deadline.to_i - current_time)/ 3600

  end

  # -------------------------------------------------------------
  def can_be_seen_by?(user)
    now = Time.now
    course_offering.is_staff?(user) ||
    (((opening_date == nil) || (opening_date <= now)) &&
      course_offering.is_enrolled?(user))
  end


  # -------------------------------------------------------------
  # Method that determines whether the given user can practice
  # this workout offering. The method looks up if the user has
  # any extension for this workout and if so 'normalizes' her
  # deadlines for this workout offering. Course staff always
  # have full access. 
  
  def can_be_practiced_by?(user)
    now = Time.now
    user_extension = StudentExtension.find_by(user: user, workout_offering: self)
    if user_extension
      normalized_hard_deadline = user_extension.hard_deadline
      normalized_soft_deadline = user_extension.soft_deadline
    else
      normalized_hard_deadline = hard_deadline
      normalized_soft_deadline = soft_deadline
    end
    course_offering.is_staff?(user) ||
    (((opening_date == nil) || (opening_date <= now)) &&
      ((normalized_hard_deadline >= now) || (normalized_soft_deadline >= now)) &&
      course_offering.is_enrolled?(user))
  end

end