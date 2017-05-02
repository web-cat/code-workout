# == Schema Information
#
# Table name: licenses
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  description       :text
#  url               :string(255)
#  license_policy_id :integer
#  created_at        :datetime
#  updated_at        :datetime
#
# Indexes
#
#  index_licenses_on_license_policy_id  (license_policy_id)
#

require 'rails_helper'

RSpec.describe License, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
