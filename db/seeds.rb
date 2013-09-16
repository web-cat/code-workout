# This file should contain all the record creation needed to seed the
# database with its default values.  The data can then be loaded with
# the rake db:seed (or created alongside the db with db:setup).

# ---------------------------------------------------------------
# Create the default course roles. The order of these must match the
# order of the IDs in models/course_role.rb.
#
CourseRole.delete_all

CourseRole.create!(
  name:                       'Instructor',
  builtin:                    true,
  can_manage_course:          true,
  can_manage_assignments:     true,
  can_grade_submissions:      true,
  can_view_other_submissions: true)

CourseRole.create!(
  name:                       'Grader',
  builtin:                    true,
  can_manage_course:          false,
  can_manage_assignments:     false,
  can_grade_submissions:      true,
  can_view_other_submissions: true)

CourseRole.create!(
  name:                       'Student',
  builtin:                    true,
  can_manage_course:          false,
  can_manage_assignments:     false,
  can_grade_submissions:      false,
  can_view_other_submissions: false)
