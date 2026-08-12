# == Schema Information
#
# Table name: test_case_results
#
#  id                      :bigint           not null, primary key
#  execution_feedback      :text(65535)
#  feedback_line_no        :integer
#  pass                    :boolean          not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  coding_prompt_answer_id :bigint
#  test_case_id            :bigint           not null
#  user_id                 :bigint           not null
#
# Indexes
#
#  index_test_case_results_on_coding_prompt_answer_id  (coding_prompt_answer_id)
#  index_test_case_results_on_test_case_id             (test_case_id)
#  index_test_case_results_on_user_id                  (user_id)
#
# Foreign Keys
#
#  fk_rails_...                                  (test_case_id => test_cases.id)
#  fk_rails_...                                  (user_id => users.id)
#  test_case_results_coding_prompt_answer_id_fk  (coding_prompt_answer_id => coding_prompt_answers.id)
#  test_case_results_test_case_id_fk             (test_case_id => test_cases.id)
#  test_case_results_user_id_fk                  (user_id => users.id)
#

# =============================================================================
# Represents the outcome of a test case on a coding prompt.
#
class TestCaseResult < ApplicationRecord

  #~ Relationships ............................................................

  belongs_to :user, inverse_of: :test_case_results
  belongs_to :test_case, inverse_of: :test_case_results
  belongs_to :coding_prompt_answer, polymorphic: true


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
