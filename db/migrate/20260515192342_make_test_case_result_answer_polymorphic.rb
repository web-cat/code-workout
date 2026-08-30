class MakeTestCaseResultAnswerPolymorphic < ActiveRecord::Migration[5.2]
  def up
    if foreign_key_exists?(:test_case_results, name: "test_case_results_coding_prompt_answer_id_fk")
      remove_foreign_key :test_case_results, name: "test_case_results_coding_prompt_answer_id_fk"
    elsif foreign_key_exists?(:test_case_results, :coding_prompt_answers)
      remove_foreign_key :test_case_results, :coding_prompt_answers
    end
    add_column :test_case_results, :coding_prompt_answer_type, :string,
      default: 'CodingPromptAnswer' unless column_exists?(:test_case_results, :coding_prompt_answer_type)
    # Backfill existing rows (all current records are CodingPromptAnswers)
    TestCaseResult.where.not(coding_prompt_answer_id: nil)
      .update_all(coding_prompt_answer_type: 'CodingPromptAnswer')
    add_index :test_case_results,
      [:coding_prompt_answer_type, :coding_prompt_answer_id],
      name: 'index_test_case_results_on_coding_prompt_answer' unless index_exists?(:test_case_results, [:coding_prompt_answer_type, :coding_prompt_answer_id], name: 'index_test_case_results_on_coding_prompt_answer')
  end

  def down
    remove_index :test_case_results,
      name: 'index_test_case_results_on_coding_prompt_answer' if index_exists?(:test_case_results, [:coding_prompt_answer_type, :coding_prompt_answer_id], name: 'index_test_case_results_on_coding_prompt_answer')
    remove_column :test_case_results, :coding_prompt_answer_type if column_exists?(:test_case_results, :coding_prompt_answer_type)
    add_foreign_key :test_case_results, :coding_prompt_answers,
      name: "test_case_results_coding_prompt_answer_id_fk" unless foreign_key_exists?(:test_case_results, :coding_prompt_answers)
  end
end
