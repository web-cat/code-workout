# == Schema Information
#
# Table name: test_cases
#
#  id                :integer          not null, primary key
#  description       :text(65535)
#  example           :boolean          default(FALSE), not null
#  expected_output   :text(65535)      not null
#  hidden            :boolean          default(FALSE), not null
#  input             :text(65535)      not null
#  negative_feedback :text(65535)
#  screening         :boolean          default(FALSE), not null
#  static            :boolean          default(FALSE), not null
#  weight            :float(24)        not null
#  created_at        :datetime
#  updated_at        :datetime
#  coding_prompt_id  :integer          not null
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
