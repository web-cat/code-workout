# == Schema Information
#
# Table name: test_cases
#
#  id                :integer          not null, primary key
#  negative_feedback :text
#  weight            :float            not null
#  description       :text
#  created_at        :datetime
#  updated_at        :datetime
#  coding_prompt_id  :integer          not null
#  input             :text             not null
#  expected_output   :text             not null
#
# Indexes
#
#  index_test_cases_on_coding_prompt_id  (coding_prompt_id)
#

# =============================================================================
# Represents a test case used to evaluate a student's answer to a coding
# prompt.
#
class TestCase < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :coding_prompt, inverse_of: :test_cases
  has_many :test_case_results, inverse_of: :test_case, dependent: :destroy


  #~ Validation ...............................................................

  validates :input, presence: true
  validates :expected_output, presence: true
  validates :coding_prompt, presence: true
  validates :weight, presence: true, numericality: { greater_than: 0 }

end
