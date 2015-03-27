# == Schema Information
#
# Table name: course_offerings
#
#  id                      :integer          not null, primary key
#  course_id               :integer          not null
#  term_id                 :integer          not null
#  name                    :string(255)      not null
#  label                   :string(255)
#  url                     :string(255)
#  self_enrollment_allowed :boolean
#  created_at              :datetime
#  updated_at              :datetime
#
# Indexes
#
#  index_course_offerings_on_course_id  (course_id)
#  index_course_offerings_on_term_id    (term_id)
#

class CourseOffering < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :course, inverse_of: :course_offerings
  belongs_to :term, inverse_of: :course_offerings
  has_many :workout_offerings, inverse_of: :course_offering,
    dependent: :destroy
  has_many :workouts, through: :workout_offerings
  has_many :course_enrollments,
    -> { CourseEnrollment.includes(:course_role, :user).order(
      'course_roles.id ASC', 'users.last_name ASC', 'users.first_name ASC') },
    inverse_of: :course_offering,
    dependent: :destroy

  accepts_nested_attributes_for :term


  #~ Validation ...............................................................

  validates :name, presence: true
  validates :course, presence: true
  validates :term, presence: true


  #~ Public instance methods ..................................................

  # -------------------------------------------------------------
  def display_name
    if label.blank?
      name
    else
      "#{name} (#{label})"
    end
  end


  # -------------------------------------------------------------
  # Public: Gets a relation representing all Users who are associated
  # with this CourseOffering.
  #
  def users
    User.includes(course_enrollments: :course_role).where(
      course_enrollments: { course_offering_id: id })
      .order(
        'course_roles.id ASC',
        'users.last_name ASC',
        'users.first_name ASC')
  end


  # -------------------------------------------------------------
  # Public: Gets a relation representing all Users who are allowed to
  # manage this CourseOffering.
  #
  def managers
    User.joins(course_enrollments: :course_role).where(
      course_enrollments: { course_offering_id: id },
      course_roles: { can_manage_course: true }).order(
        'users.last_name ASC',
        'users.first_name ASC')
  end


  # -------------------------------------------------------------
  # Public: Gets a relation representing all Users who are students in
  # this CourseOffering.
  #
  def students
    User.joins(course_enrollments: :course_role).where(
      course_enrollments: {
        course_offering_id: id,
        course_role_id: CourseRole.student
      }).order(
        'users.last_name ASC',
        'users.first_name ASC')
  end


  # -------------------------------------------------------------
  # Public: Gets a relation representing all Users who are instructors in
  # this CourseOffering.
  #
  def instructors
    User.joins(course_enrollments: :course_role).where(
      course_enrollments: {
        course_offering_id: id,
        course_role_id: CourseRole.instructor
      }).order(
        'users.last_name ASC',
        'users.first_name ASC')
  end


  # -------------------------------------------------------------
  # Public: Gets a relation representing all Users who are graders in
  # this CourseOffering.
  #
  def graders
    User.joins(course_enrollments: :course_role).where(
      course_enrollments: {
        course_offering_id: id,
        course_role_id: CourseRole.grader
      }).order(
        'users.last_name ASC',
        'users.first_name ASC')
  end


  # -------------------------------------------------------------
  def other_concurrent_offerings
    course.course_offerings.where('term_id = ? and id != ?', term.id, id)
  end


  # -------------------------------------------------------------
  def enrolled?(user)
    user && course_enrollments.where(user_id: user.id).any?
  end


  # -------------------------------------------------------------
  def manages?(user)
    role_for_user(user).andand.can_manage_course
  end


  # -------------------------------------------------------------
  def role_for_user(user)
    user && course_enrollments.where(user_id: user.id).first.andand.course_role
  end

end
