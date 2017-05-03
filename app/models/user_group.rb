# == Schema Information
#
# Table name: user_groups
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class UserGroup < ActiveRecord::Base
  has_many :memberships
  has_many :users, through: :memberships
  has_one :exercise_collection

  def not_in_group
    User.where.not(id: self.users.flat_map(&:id))
  end
end
