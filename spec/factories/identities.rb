# == Schema Information
#
# Table name: identities
#
#  id         :bigint           not null, primary key
#  provider   :string(255)      not null
#  uid        :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_identities_on_uid_and_provider  (uid,provider)
#  index_identities_on_user_id           (user_id)
#
# Foreign Keys
#
#  fk_rails_...           (user_id => users.id)
#  identities_user_id_fk  (user_id => users.id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :identity do
    user { nil }
    provider { "MyString" }
    uid { "MyString" }
  end
end
