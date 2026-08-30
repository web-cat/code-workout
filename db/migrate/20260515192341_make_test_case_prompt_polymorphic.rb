class MakeTestCasePromptPolymorphic < ActiveRecord::Migration[5.2]
  def up
    if foreign_key_exists?(:test_cases, name: "test_cases_coding_prompt_id_fk")
      remove_foreign_key :test_cases, name: "test_cases_coding_prompt_id_fk"
    elsif foreign_key_exists?(:test_cases, :coding_prompts)
      remove_foreign_key :test_cases, :coding_prompts
    end
    add_column :test_cases, :coding_prompt_type, :string, null: false, default: 'CodingPrompt' unless column_exists?(:test_cases, :coding_prompt_type)
    add_index :test_cases, [:coding_prompt_type, :coding_prompt_id],
      name: 'index_test_cases_on_coding_prompt' unless index_exists?(:test_cases, [:coding_prompt_type, :coding_prompt_id], name: 'index_test_cases_on_coding_prompt')
  end

  def down
    remove_index :test_cases, name: 'index_test_cases_on_coding_prompt' if index_exists?(:test_cases, [:coding_prompt_type, :coding_prompt_id], name: 'index_test_cases_on_coding_prompt')
    remove_column :test_cases, :coding_prompt_type if column_exists?(:test_cases, :coding_prompt_type)
    add_foreign_key :test_cases, :coding_prompts,
      name: "test_cases_coding_prompt_id_fk" unless foreign_key_exists?(:test_cases, :coding_prompts)
  end
end
