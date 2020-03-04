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

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :license_policy do
    name { "MyString" }
    description { "MyText" }
    can_fork { false }
    is_public { false }
  end
end
