# == Schema Information
#
# Table name: user_groups
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  description :text(65535)
#

class UserGroup < ActiveRecord::Base
  has_many :memberships
  has_many :users, through: :memberships
  has_many :group_access_requests, inverse_of: :user_group
  has_one :exercise_collection, inverse_of: :user_group
  has_one :course

  accepts_nested_attributes_for :memberships

  def add_user_to_group(user)
    unless user.nil?
      return Membership.create user: user, user_group: self
    end
  end
end
