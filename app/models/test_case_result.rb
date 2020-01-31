# == Schema Information
#
# Table name: test_case_results
#
#  id                      :integer          not null, primary key
#  test_case_id            :integer          not null
#  user_id                 :integer          not null
#  execution_feedback      :text(65535)
#  feedback_line_no        :integer
#  created_at              :datetime
#  updated_at              :datetime
#  pass                    :boolean          not null
#  coding_prompt_answer_id :integer
#
# Indexes
#
#  index_test_case_results_on_coding_prompt_answer_id  (coding_prompt_answer_id)
#  index_test_case_results_on_test_case_id             (test_case_id)
#  index_test_case_results_on_user_id                  (user_id)
#

# =============================================================================
# Represents the outcome of a test case on a coding prompt.
#
class TestCaseResult < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :user, inverse_of: :test_case_results
  belongs_to :test_case,
    -> { includes :coding_prompt },
    inverse_of: :test_case_results
  belongs_to :coding_prompt_answer, inverse_of: :test_case_results


  #~ Validation ...............................................................

  validates :user, presence: true
  validates :test_case, presence: true
  validates :coding_prompt_answer, presence: true
  validates :pass, inclusion: [true, false]


  #~ Instance methods .........................................................

  # -------------------------------------------------------------
  # Provides the associated test case's displayable description,
  # computing it if needed
  def display_description
    test_case.display_description(self.pass)
  end

end
