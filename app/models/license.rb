# == Schema Information
#
# Table name: licenses
#
#  id                :bigint           not null, primary key
#  description       :text(65535)
#  name              :string(255)
#  url               :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  license_policy_id :bigint
#
# Indexes
#
#  index_licenses_on_license_policy_id  (license_policy_id)
#
# Foreign Keys
#
#  fk_rails_...  (license_policy_id => license_policies.id)
#

class License < ApplicationRecord
  belongs_to :license_policy, inverse_of: :licenses
  has_many :exercise_collections
end
