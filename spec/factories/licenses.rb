# == Schema Information
#
# Table name: licenses
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  description       :text(65535)
#  url               :string(255)
#  license_policy_id :integer
#  created_at        :datetime
#  updated_at        :datetime
#
# Indexes
#
#  index_licenses_on_license_policy_id  (license_policy_id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :license do
    name { "MyString" }
    description { "MyText" }
    url { "MyString" }
    license_policy { nil }
  end
end
