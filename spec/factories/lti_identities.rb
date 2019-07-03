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

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :lti_identity do
    lti_user_id { "MyString" }
    user { nil }
    lms_instance { nil }
  end
end
