class CreateTestCaseResults < ActiveRecord::Migration
  def change
    create_table :test_case_results do |t|
      t.integer :test_case_id, index: true
      t.integer :user_id, index: true
      t.float :score, null: false
      t.float :max, default: 1.0
      t.text :execution_feedback
      t.timestamps
    end

  end
end
