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

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :course_enrollment do
    course_offering_id { 1 }
    course_role        { CourseRole.student }
    user_id { 1 }
  end
end
