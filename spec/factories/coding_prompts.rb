# == Schema Information
#
# Table name: coding_prompts
#
#  id            :integer          not null, primary key
#  created_at    :datetime
#  updated_at    :datetime
#  class_name    :string(255)
#  wrapper_code  :text(65535)      not null
#  test_script   :text(65535)      not null
#  method_name   :string(255)
#  starter_code  :text(65535)
#  hide_examples :boolean          default(FALSE), not null
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :coding_prompt do
  end
end
