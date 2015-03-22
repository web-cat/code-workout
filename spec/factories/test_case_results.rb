# == Schema Information
#
# Table name: test_case_results
#
#  id                 :integer          not null, primary key
#  test_case_id       :integer
#  user_id            :integer
#  execution_feedback :text
#  created_at         :datetime
#  updated_at         :datetime
#  pass               :boolean
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :test_case_result do
    test_case_id 1
    user_id 1
    score ""
    execution_feedback "MyText"
  end
end
