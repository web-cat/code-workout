# == Schema Information
#
# Table name: time_zones
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  zone       :string(255)
#  display_as :string(255)
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :time_zone do
    name { "MyString" }
    zone { "MyString" }
    display_as { "MyString" }
  end
end
