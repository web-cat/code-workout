# == Schema Information
#
# Table name: lti_identities
#
#  id              :integer          not null, primary key
#  created_at      :datetime
#  updated_at      :datetime
#  lms_instance_id :integer
#  lti_user_id     :string(255)
#  user_id         :integer
#
# Indexes
#
#  index_lti_identities_on_lms_instance_id  (lms_instance_id)
#  index_lti_identities_on_lti_user_id      (lti_user_id)
#  index_lti_identities_on_user_id          (user_id)
#

class LtiIdentity < ActiveRecord::Base
  belongs_to :user
  belongs_to :lms_instance
end
