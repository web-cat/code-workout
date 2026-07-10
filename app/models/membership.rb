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

class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :user_group
end
