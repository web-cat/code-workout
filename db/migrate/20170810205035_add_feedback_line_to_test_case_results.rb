class AddFeedbackLineToTestCaseResults < ActiveRecord::Migration
  def change
    add_column :test_case_results, :feedback_line, :text, :after => :execution_feedback
  end
end
