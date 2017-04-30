# == Schema Information
#
# Table name: course_roles
#
#  id                         :integer          not null, primary key
#  name                       :string(255)      default(""), not null
#  can_manage_course          :boolean          default(FALSE), not null
#  can_manage_assignments     :boolean          default(FALSE), not null
#  can_grade_submissions      :boolean          default(FALSE), not null
#  can_view_other_submissions :boolean          default(FALSE), not null
#  builtin                    :boolean          default(FALSE), not null
#

# =============================================================================
# Represents the role a user has with respect to a course offering in which
# the user is enrolled.  Roles are stored in the CourseEnrollment relationship.
#
class CourseRole < ActiveRecord::Base

  #~ Validation ...............................................................

  validates :name, presence: true, uniqueness: true

  with_options if: :builtin?, on: :update, changeable: false do |builtin|
    builtin.validates :can_manage_course
    builtin.validates :can_manage_assignments
    builtin.validates :can_grade_submissions
    builtin.validates :can_view_other_submissions
  end


  #~ Hooks ....................................................................

  before_destroy :check_builtin?


  #~ Constants ................................................................

  # Make sure to run rake db:seed after initial database creation
  # to ensure that the built-in roles with these IDs are created.
  # These IDs should not be referred to directly in most cases;
  # use the class methods below to fetch the actual role object
  # instead.
  INSTRUCTOR_ID      = 1
  GRADER_ID          = 2
  STUDENT_ID         = 3

  ROLES = {
    'Instructor' => INSTRUCTOR_ID,
    'Grader' => GRADER_ID,
    'Student' => STUDENT_ID
  }


  #~ Class methods ............................................................

  # -------------------------------------------------------------
  def self.instructor
    find(INSTRUCTOR_ID)
  end


  # -------------------------------------------------------------
  def self.grader
    find(GRADER_ID)
  end


  # -------------------------------------------------------------
  def self.student
    find(STUDENT_ID)
  end


  # -------------------------------------------------------------
  def self.all_roles
    ROLES
  end


  #~ Public instance methods ..................................................

  # -------------------------------------------------------------
  def is_staff?
    can_manage_course? ||
    can_manage_assignments? ||
    can_grade_submissions? ||
    can_view_other_submissions?
  end


  # -------------------------------------------------------------
  def order_number
    number = 0
    number |= 8 if can_manage_course?
    number |= 4 if can_manage_assignments?
    number |= 2 if can_grade_submissions?
    number |= 1 if can_view_other_submissions?
    number
  end


  # -------------------------------------------------------------
  def is_instructor?
    id == INSTRUCTOR_ID
  end


  # -------------------------------------------------------------
  def is_grader?
    id == GRADER_ID
  end


  # -------------------------------------------------------------
  def is_student?
    id == STUDENT_ID
  end


  #~ Private instance methods .................................................

  private

  # -------------------------------------------------------------
  def check_builtin?
    errors.add :base, 'Cannot delete built-in roles.' if builtin?
    errors.blank?
  end

end
