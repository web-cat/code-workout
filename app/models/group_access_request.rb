# == Schema Information
#
# Table name: group_access_requests
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  user_group_id :integer
#  pending       :boolean          default(TRUE)
#  decision      :boolean
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_group_access_requests_on_user_group_id  (user_group_id)
#  index_group_access_requests_on_user_id        (user_id)
#

class GroupAccessRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :user_group
end
