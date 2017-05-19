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
  has_one :course

  def add_user_to_group(user)
    unless user.nil?
      Membership.create user: user, user_group: self
    end
  end
end
