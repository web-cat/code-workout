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

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :license_policy do
    name { "MyString" }
    description { "MyText" }
    can_fork { false }
    is_public { false }
  end
end
