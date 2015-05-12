# == Schema Information
#
# Table name: course_offerings
#
#  id                      :integer          not null, primary key
#  course_id               :integer          not null
#  term_id                 :integer          not null
#  label                   :string(255)      not null
#  url                     :string(255)
#  self_enrollment_allowed :boolean
#  created_at              :datetime
#  updated_at              :datetime
#  cutoff_date             :date
#
# Indexes
#
#  index_course_offerings_on_course_id  (course_id)
#  index_course_offerings_on_term_id    (term_id)
#

# =============================================================================
# Represents a single section (or offering) of a course in a specific term.
#
class CourseOffering < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :course, inverse_of: :course_offerings
  belongs_to :term, inverse_of: :course_offerings
  has_many :workout_offerings, inverse_of: :course_offering,
    dependent: :destroy
  has_many :workouts, through: :workout_offerings
  has_many :course_enrollments,
    -> { includes(:course_role, :user).order(
      'course_roles.id ASC', 'users.last_name ASC', 'users.first_name ASC') },
    inverse_of: :course_offering,
    dependent: :destroy
  has_many :users, through: :course_enrollments

  accepts_nested_attributes_for :term


  #~ Validation ...............................................................

  validates :label, presence: true
  validates :course, presence: true
  validates :term, presence: true

  #~ Public instance methods ..................................................

  # -------------------------------------------------------------
  def display_name
    "#{course.number} (#{label})"
  end

  def name
    self.course.name + ' - ' + self.term.display_name
  end


  # -------------------------------------------------------------
  def display_name_with_term
    "#{course.number} (#{term.display_name}, #{label})"
  end


  # -------------------------------------------------------------
  # Public: Gets a relation representing all Users who are allowed to
  # manage this CourseOffering.
  #
  def managers
    course_enrollments.where(course_roles: { can_manage_course: true }).
      map(&:user)
  end


  # -------------------------------------------------------------
  # Public: Gets a relation representing all Users who are students in
  # this CourseOffering.
  #
  def students
    course_enrollments.where(course_role: CourseRole.student).map(&:user)
  end


  # -------------------------------------------------------------
  # Public: Gets a relation representing all Users who are instructors in
  # this CourseOffering.
  #
  def instructors
    course_enrollments.where(course_role: CourseRole.instructor).map(&:user)
  end

  # -------------------------------------------------------------
  # Public: Returns a boolean indicating whether the offering is
  # currently unavailable for self-enrollment
  def cutoff?
    if self_enrollment_allowed
      if !cutoff_date
        return false        
      else
        if cutoff_date >= Time.now
          return false  
        end
      end
    end
    return true
  end

  # -------------------------------------------------------------
  # Public: Gets a relation representing all Users who are graders in
  # this CourseOffering.
  #
  def graders
    course_enrollments.where(course_role: CourseRole.grader).map(&:user)
  end


  # -------------------------------------------------------------
  def other_concurrent_offerings
    course.course_offerings.where(term: term, course: course)
  end


  # -------------------------------------------------------------
  def is_enrolled?(user)
    user && users.include?(user)
  end


  # -------------------------------------------------------------
  def managed_by?(user)
    role_for_user(user).andand.can_manage_course?
  end


  # -------------------------------------------------------------
  def taught_by?(user)
    role_for_user(user).andand.is_instructor?
  end


  # -------------------------------------------------------------
  def graded_by?(user)
    role_for_user(user).andand.can_grade_submissions?
  end


  # -------------------------------------------------------------
  def is_staff?(user)
    role_for_user(user).andand.is_staff?
  end

  # -------------------------------------------------------------
  def is_student?(user)
    role_for_user(user).andand.is_student?
  end

  # -------------------------------------------------------------
  def role_for_user(user)
    user && course_enrollments.where(user: user).first.andand.course_role
  end

end
