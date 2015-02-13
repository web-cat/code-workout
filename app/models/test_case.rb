class TestCase < ActiveRecord::Base
  #~ relationships
  belongs_to :coding_question
  has_many :test_case_results
  
  #~ Validations
  validates :input, presence: true
  validates :expected_output, presence: true
  validates :negative_feedback, presence: true
  
end
