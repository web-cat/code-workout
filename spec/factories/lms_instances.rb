# == Schema Information
#
# Table name: lms_instances
#
#  id              :bigint           not null, primary key
#  consumer_key    :string(255)
#  consumer_secret :string(255)
#  url             :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  lms_type_id     :bigint
#  organization_id :bigint
#
# Indexes
#
#  index_lms_instances_on_lms_type_id      (lms_type_id)
#  index_lms_instances_on_organization_id  (organization_id)
#  index_lms_instances_on_url              (url) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (lms_type_id => lms_types.id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :lms_instance do
    consumer_key { "MyString" }
    consumer_secret { "MyString" }
  end
end
