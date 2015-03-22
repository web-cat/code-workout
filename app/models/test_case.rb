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

class TestCase < ActiveRecord::Base
  #~ relationships
  belongs_to :coding_question
  has_many :test_case_results
  
  #~ Validations
  validates :input, presence: true
  validates :expected_output, presence: true
  validates :negative_feedback, presence: true
  
end
