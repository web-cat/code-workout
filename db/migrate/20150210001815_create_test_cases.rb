class CreateTestCases < ActiveRecord::Migration
  def change
    create_table :test_cases do |t|
      t.string :test_script
      t.text :negative_feedback
      t.float :weight
      t.text :description
      t.string :input
      t.string :expected_output
 
      t.timestamps
    end
    add_reference :test_cases, :coding_question, index: true
  end
end
