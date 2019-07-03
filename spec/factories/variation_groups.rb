# == Schema Information
#
# Table name: variation_groups
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :variation_group do
    title { "MyString" }
  end
end
