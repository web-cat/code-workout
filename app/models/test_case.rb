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

# This require is to prevent autoload circular dependencies, since
# TestCaseResult is used in one of the methods.
require 'test_case_result'


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


  #~ Instance methods .........................................................

  # -------------------------------------------------------------
  def record_result(answer, test_results_array)
    tcr = TestCaseResult.new(
      test_case: self,
      user: answer.attempt.user,
      coding_prompt_answer: answer,
      pass: (test_results_array[7].to_i == 1)
      )
    if !self.negative_feedback.blank?
      tcr.execution_feedback = self.negative_feedback
    elsif !test_results_array[6].blank? && 'null' != test_results_array[6]
      tcr.execution_feedback = test_results_array[6]
    elsif !test_results_array[5].blank?
      tcr.execution_feedback = test_results_array[5].sub(/^.*\./, '')
    else
      tcr.execution_feedback = 'did not meet expectations'
    end
    tcr.save!

    # Return weighted score for this test result
    tcr.pass? ? self.weight : 0.0
  end


  # -------------------------------------------------------------
  def to_code(language)
    TEST_METHOD_TEMPLATES[language] % {
      id: self.id.to_s,
      method_name: coding_prompt.method_name,
      class_name: coding_prompt.class_name,
      input: self.input,
      expected_output: self.expected_output,
      negative_feedback: self.negative_feedback
    }
  end


  #~ Private instance methods .................................................
  private

    TEST_METHOD_TEMPLATES = {
      'Ruby' => <<RUBY_TEST,
  def test%{id}
    if %{method_name}(%{input}) ==
      %{expected_output}
      @@f.write("1,,%{id}\n")
    else
      @@f.write("0,\"%{negative_feedback}\",%{id}\n")
    end
    assert_equal(%{method_name}(%{input}), %{expected_output})
  end

RUBY_TEST
      'Python' => <<PYTHON_TEST,
    def test%{id}(self):
        if %{class_name}.%{method_name}(%{input}) == %{expected_output}:
            %{class_name}Test.f.write("1,,%{id}\n")
        else:
            %{class_name}Test.f.write("0,\"%{negative_feedback}\",%{id}\n")
        self.assertEqual(%{class_name}.%{method_name}(%{input}),%{expected_output})

PYTHON_TEST
      'Java' => <<JAVA_TEST
    @Test
    public void test%{id}()
    {
        assertEquals(
          "%{negative_feedback}",
          %{expected_output},
          subject.%{method_name}(%{input}));
    }
JAVA_TEST
    }

end
