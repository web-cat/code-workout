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

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :course_role do
    name { "Test Role" }
    can_manage_course { false }
    can_manage_assignments { false }
    can_grade_submissions { false }
    can_view_other_submissions { false }
    builtin { false }
  end
end
