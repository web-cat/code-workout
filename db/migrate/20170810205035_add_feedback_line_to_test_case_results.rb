class AddFeedbackLineToTestCaseResults < ActiveRecord::Migration[5.1]
  def change
    add_column :test_case_results, :feedback_line_no, :integer,
      :after => :execution_feedback
    add_column :coding_prompt_answers, :error_line_no, :integer,
      :after => :error
  end
end
