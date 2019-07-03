# == Schema Information
#
# Table name: identities
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  provider   :string(255)      default(""), not null
#  uid        :string(255)      default(""), not null
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_identities_on_uid_and_provider  (uid,provider)
#  index_identities_on_user_id           (user_id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :identity do
    user { nil }
    provider { "MyString" }
    uid { "MyString" }
  end
end
