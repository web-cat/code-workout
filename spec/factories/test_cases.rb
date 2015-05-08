# == Schema Information
#
# Table name: test_cases
#
#  id                :integer          not null, primary key
#  test_script       :string(255)
#  negative_feedback :text             not null
#  weight            :float            not null
#  description       :text
#  input             :string(255)      not null
#  expected_output   :string(255)      not null
#  created_at        :datetime
#  updated_at        :datetime
#  coding_prompt_id  :integer          not null
#
# Indexes
#
#  index_test_cases_on_coding_prompt_id  (coding_prompt_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :test_case do
    test_script "MyString"
    negative_feedback "MyText"
    weight 1.5
    description "MyText"
    input "MyString"
    expected_output "MyString"
  end
end
