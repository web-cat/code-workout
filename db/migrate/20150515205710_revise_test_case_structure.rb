class ReviseTestCaseStructure < ActiveRecord::Migration
  def up
    change_table :test_cases do |t|
      t.remove :test_script, :string
      t.remove :input, :string
      t.remove :expected_output, :string

      t.text :input
      t.text :expected_output
    end
    change_column_null :test_cases, :negative_feedback, true
    change_column_null :test_cases, :input, false
    change_column_null :test_cases, :expected_output, false
    change_column_null :coding_prompt_answers, :answer, true
  end

  def down
    change_table :test_cases do |t|
      t.remove :input, :text
      t.remove :expected_output, :text

      t.string :test_script
      t.string :input
      t.string :expected_output
    end
    change_column_null :test_cases, :negative_feedback, false
    change_column_null :test_cases, :input, false
    change_column_null :test_cases, :expected_output, false
    change_column_null :coding_prompt_answers, :answer, false
  end
end
