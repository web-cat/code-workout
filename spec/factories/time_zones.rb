# == Schema Information
#
# Table name: time_zones
#
#  id         :bigint           not null, primary key
#  display_as :string(255)
#  name       :string(255)
#  zone       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :time_zone do
    name { "MyString" }
    zone { "MyString" }
    display_as { "MyString" }
  end
end
