# == Schema Information
#
# Table name: license_policies
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text
#  can_fork    :boolean
#  is_public   :boolean
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

RSpec.describe LicensePolicy, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
