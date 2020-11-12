class RenameCodingQuestionInTestCases < ActiveRecord::Migration[5.1]
  def change
    rename_column :test_cases, :coding_question_id, :coding_prompt_id
  end
end
