# == Schema Information
#
# Table name: lti_identities
#
#  id              :integer          not null, primary key
#  lti_user_id     :string(255)
#  user_id         :integer
#  lms_instance_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#
# Indexes
#
#  index_lti_identities_on_lms_instance_id  (lms_instance_id)
#  index_lti_identities_on_user_id          (user_id)
#

class LtiIdentity < ActiveRecord::Base
  belongs_to :user
  belongs_to :lms_instance
end
