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

class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :user_group
end
