# == Schema Information
#
# Table name: lms_instances
#
#  id              :integer          not null, primary key
#  consumer_key    :string(255)
#  consumer_secret :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  url             :string(255)
#  lms_type_id     :integer
#  organization_id :integer
#
# Indexes
#
#  index_lms_instances_on_organization_id  (organization_id)
#  index_lms_instances_on_url              (url) UNIQUE
#  lms_instances_lms_type_id_fk            (lms_type_id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :lms_instance do
    consumer_key { "MyString" }
    consumer_secret { "MyString" }
  end
end
