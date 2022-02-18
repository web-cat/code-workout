class CreateStudentTestCaseResults < ActiveRecord::Migration
  def change
    #drop_table :student_test_case_results
    create_table :student_test_case_results do |t|
      t.integer :test_case_id
      t.string :feedback
      t.boolean :pass
      t.references :coding_prompt_answer
    end
  end
end
