<<<<<<< 9044d3db329f8e33128a87b26521bc44a948f1b8
# == Schema Information
#
# Table name: memberships
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  user_group_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#
# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :membership do
  end
end
