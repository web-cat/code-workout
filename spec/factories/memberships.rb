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

FactoryBot.define do
  factory :membership do
  end
end
