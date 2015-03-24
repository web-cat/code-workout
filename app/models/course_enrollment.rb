# == Schema Information
#
# Table name: course_enrollments
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  course_offering_id :integer
#  course_role_id     :integer
#
# Indexes
#
#  index_course_enrollments_on_course_offering_id              (course_offering_id)
#  index_course_enrollments_on_course_role_id                  (course_role_id)
#  index_course_enrollments_on_user_id                         (user_id)
#  index_course_enrollments_on_user_id_and_course_offering_id  (user_id,course_offering_id) UNIQUE
#

class CourseEnrollment < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :user, inverse_of: :course_enrollments
  belongs_to :course_offering, inverse_of: :course_enrollments
  belongs_to :course_role

  paginates_per 100

end
