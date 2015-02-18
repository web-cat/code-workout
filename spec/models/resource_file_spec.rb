# == Schema Information
#
# Table name: resource_files
#
#  id         :integer          not null, primary key
#  filename   :string(255)
#  token      :string(255)
#  user_id    :integer
#  public     :boolean          default(TRUE)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe ResourceFile do
  pending "add some examples to (or delete) #{__FILE__}"
end
