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

class LicensePolicy < ActiveRecord::Base
  has_many :licenses
end
