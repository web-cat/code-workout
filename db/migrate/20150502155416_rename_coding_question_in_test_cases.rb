class RenameCodingQuestionInTestCases < ActiveRecord::Migration
  def change
    rename_column :test_cases, :coding_question_id, :coding_prompt_id
  end
end
