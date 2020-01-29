# == Schema Information
#
# Table name: license_policies
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text(65535)
#  can_fork    :boolean
#  is_public   :boolean
#  created_at  :datetime
#  updated_at  :datetime
#

class LicensePolicy < ActiveRecord::Base
  has_many :licenses, inverse_of: :license_policy
  accepts_nested_attributes_for :licenses
end
