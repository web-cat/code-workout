# == Schema Information
#
# Table name: memberships
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_group_id :integer
#  user_id       :integer
#

FactoryBot.define do
  factory :membership do
  end
end
