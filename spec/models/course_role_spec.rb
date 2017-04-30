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

require 'spec_helper'

describe CourseRole do
  pending "add some examples to (or delete) #{__FILE__}"
end
