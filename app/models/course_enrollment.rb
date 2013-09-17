# == Schema Information
#
# Table name: course_enrollments
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  course_offering_id :integer
#  course_role_id     :integer
#

class CourseEnrollment < ActiveRecord::Base

  belongs_to :user
  belongs_to :course_offering
  belongs_to :course_role

  paginates_per 100

end
