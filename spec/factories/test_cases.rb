# == Schema Information
#
# Table name: test_cases
#
#  id                 :integer          not null, primary key
#  test_script        :string(255)
#  negative_feedback  :text
#  weight             :float
#  description        :text
#  input              :string(255)
#  expected_output    :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  coding_question_id :integer
#
# Indexes
#
#  index_test_cases_on_coding_question_id  (coding_question_id)
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
