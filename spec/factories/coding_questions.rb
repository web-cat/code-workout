# == Schema Information
#
# Table name: coding_questions
#
#  id           :integer          not null, primary key
#  created_at   :datetime
#  updated_at   :datetime
#  exercise_id  :integer
#  class_name   :string(255)
#  wrapper_code :text
#  test_script  :text
#  method_name  :string(255)
#  starter_code :text
#
# Indexes
#
#  index_coding_questions_on_exercise_id  (exercise_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :coding_question do
    base_class "MyString"
    wrapper_code "MyText"
    test_script "MyText"
  end
end
