# == Schema Information
#
# Table name: coding_questions
#
#  id                  :integer          not null, primary key
#  created_at          :datetime
#  updated_at          :datetime
#  exercise_version_id :integer          not null
#  class_name          :string(255)
#  wrapper_code        :text             not null
#  test_script         :text             not null
#  method_name         :string(255)
#  starter_code        :text
#
# Indexes
#
#  index_coding_questions_on_exercise_version_id  (exercise_version_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :coding_question do
    base_class "MyString"
    wrapper_code "MyText"
    test_script "MyText"
  end
end
