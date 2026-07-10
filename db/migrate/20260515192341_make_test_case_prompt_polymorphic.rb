class MakeTestCasePromptPolymorphic < ActiveRecord::Migration[5.2]
  def up
    remove_foreign_key :test_cases, name: "test_cases_coding_prompt_id_fk"
    add_column :test_cases, :coding_prompt_type, :string, null: false, default: 'CodingPrompt'
    add_index :test_cases, [:coding_prompt_type, :coding_prompt_id],
      name: 'index_test_cases_on_coding_prompt'
  end

  def down
    remove_index :test_cases, name: 'index_test_cases_on_coding_prompt'
    remove_column :test_cases, :coding_prompt_type
    add_foreign_key :test_cases, :coding_prompts,
      name: "test_cases_coding_prompt_id_fk"
  end
end
