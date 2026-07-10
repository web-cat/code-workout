class MakeTestCaseResultAnswerPolymorphic < ActiveRecord::Migration[5.2]
  def up
    remove_foreign_key :test_case_results,
      name: "test_case_results_coding_prompt_answer_id_fk"
    add_column :test_case_results, :coding_prompt_answer_type, :string,
      default: 'CodingPromptAnswer'
    # Backfill existing rows (all current records are CodingPromptAnswers)
    TestCaseResult.where.not(coding_prompt_answer_id: nil)
      .update_all(coding_prompt_answer_type: 'CodingPromptAnswer')
    add_index :test_case_results,
      [:coding_prompt_answer_type, :coding_prompt_answer_id],
      name: 'index_test_case_results_on_coding_prompt_answer'
  end

  def down
    remove_index :test_case_results,
      name: 'index_test_case_results_on_coding_prompt_answer'
    remove_column :test_case_results, :coding_prompt_answer_type
    add_foreign_key :test_case_results, :coding_prompt_answers,
      name: "test_case_results_coding_prompt_answer_id_fk"
  end
end
