# == Schema Information
#
# Table name: coding_prompts
#
#  id            :bigint           not null, primary key
#  class_name    :string(255)
#  hide_examples :boolean          default(FALSE), not null
#  method_name   :string(255)
#  starter_code  :text(65535)
#  test_script   :text(65535)      not null
#  wrapper_code  :text(65535)      not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :coding_prompt do
  end
end
