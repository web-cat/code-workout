# == Schema Information
#
# Table name: coding_prompts
#
#  id            :integer          not null, primary key
#  created_at    :datetime
#  updated_at    :datetime
#  class_name    :string(255)
#  wrapper_code  :text             not null
#  test_script   :text             not null
#  method_name   :string(255)
#  starter_code  :text
#  hide_examples :boolean          default(FALSE), not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :coding_prompt do
  end
end
