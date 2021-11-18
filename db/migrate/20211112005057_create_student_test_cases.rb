class CreateStudentTestCases < ActiveRecord::Migration
  def change
    create_table :student_test_cases do |t|
      t.string :input
      t.string :expected_output
      t.references :coding_prompt_answer
    end
  end
end
