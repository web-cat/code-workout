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

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :user_group do
    name { 'mcq-group' }
  end
end
