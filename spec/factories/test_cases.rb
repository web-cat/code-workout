# == Schema Information
#
# Table name: test_cases
#
#  id                :integer          not null, primary key
#  negative_feedback :text(65535)
#  weight            :float(24)        not null
#  description       :text(65535)
#  created_at        :datetime
#  updated_at        :datetime
#  coding_prompt_id  :integer          not null
#  input             :text(65535)      not null
#  expected_output   :text(65535)      not null
#  static            :boolean          default(FALSE), not null
#  screening         :boolean          default(FALSE), not null
#  example           :boolean          default(FALSE), not null
#  hidden            :boolean          default(FALSE), not null
#
# Indexes
#
#  index_test_cases_on_coding_prompt_id  (coding_prompt_id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :test_case do
    test_script { "MyString" }
    negative_feedback { "MyText" }
    weight { 1.5 }
    description { "MyText" }
    input { "MyString" }
    expected_output { "MyString" }
  end
end
