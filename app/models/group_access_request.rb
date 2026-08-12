# == Schema Information
#
# Table name: group_access_requests
#
#  id            :bigint           not null, primary key
#  decision      :boolean
#  pending       :boolean          default(TRUE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_group_id :bigint
#  user_id       :bigint
#
# Indexes
#
#  index_group_access_requests_on_user_group_id  (user_group_id)
#  index_group_access_requests_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_group_id => user_groups.id)
#  fk_rails_...  (user_id => users.id)
#

class GroupAccessRequest < ApplicationRecord
  belongs_to :user
  belongs_to :user_group
end
