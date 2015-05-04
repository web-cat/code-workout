class AddAttemptsToTestCaseResult < ActiveRecord::Migration
  def change
    add_reference :test_case_results, :attempt, index: true
  end
end
