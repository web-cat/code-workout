class CourseEnrollment < ActiveRecord::Base

  belongs_to :user
  belongs_to :course_offering
  belongs_to :course_role

  paginates_per 100

end
