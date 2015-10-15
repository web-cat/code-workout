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

require 'spec_helper'

describe GlobalRole do
  pending "add some examples to (or delete) #{__FILE__}"
end
