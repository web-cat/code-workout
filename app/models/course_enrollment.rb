# == Schema Information
#
# Table name: course_enrollments
#
#  id                 :integer          not null, primary key
#  user_id            :integer          not null
#  course_offering_id :integer          not null
#  course_role_id     :integer          not null
#
# Indexes
#
#  index_course_enrollments_on_course_offering_id              (course_offering_id)
#  index_course_enrollments_on_course_role_id                  (course_role_id)
#  index_course_enrollments_on_user_id                         (user_id)
#  index_course_enrollments_on_user_id_and_course_offering_id  (user_id,course_offering_id) UNIQUE
#

# =============================================================================
# Represents a many-to-many relationship between course offerings and users,
# indicating each user's role with respect to the course offerings in which
# they are enrolled.
#
class CourseEnrollment < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :user, inverse_of: :course_enrollments
  belongs_to :course_offering, inverse_of: :course_enrollments
  belongs_to :course_role

  paginates_per 100 

  #~ Validation ...............................................................

  validates :user, presence: true
  validates :course_offering, presence: true
  validates :course_role, presence: true

end
