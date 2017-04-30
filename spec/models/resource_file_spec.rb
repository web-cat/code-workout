# == Schema Information
#
# Table name: resource_files
#
#  id         :integer          not null, primary key
#  filename   :string(255)
#  token      :string(255)      default(""), not null
#  user_id    :integer          not null
#  public     :boolean          default(TRUE)
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_resource_files_on_token    (token)
#  index_resource_files_on_user_id  (user_id)
#

require 'spec_helper'

describe ResourceFile do
  pending "add some examples to (or delete) #{__FILE__}"
end
