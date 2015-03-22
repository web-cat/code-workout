# == Schema Information
#
# Table name: courses
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  number          :string(255)
#  organization_id :integer
#  url_part        :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

require 'spec_helper'

describe Course do
  pending "add some examples to (or delete) #{__FILE__}"
end
