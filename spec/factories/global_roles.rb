# == Schema Information
#
# Table name: global_roles
#
#  id                            :integer          not null, primary key
#  name                          :string(255)      default(""), not null
#  can_manage_all_courses        :boolean          default(FALSE), not null
#  can_edit_system_configuration :boolean          default(FALSE), not null
#  builtin                       :boolean          default(FALSE), not null
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :global_role_admin do
    name { "Administrator" }
    can_manage_all_courses { true }
    can_edit_system_configuration { true }
    builtin { true }
  end

  factory :global_role_instructor do
  	name { "Instructor" }
  	can_manage_all_courses { false }
  	can_edit_system_configuration { false }
  	builtin { false }
  end

  factory :global_role_user do
  	name { "Regular User" }
 	  can_manage_all_courses { false }
  	can_edit_system_configuration { false }
 	  builtin { false }
  end
end
