# == Schema Information
#
# Table name: license_policies
#
#  id          :bigint           not null, primary key
#  can_fork    :boolean
#  description :text(65535)
#  is_public   :boolean
#  name        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class LicensePolicy < ApplicationRecord
  has_many :licenses, inverse_of: :license_policy
  accepts_nested_attributes_for :licenses
end
