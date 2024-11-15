class RectifyTestCaseResult < ActiveRecord::Migration[5.1]
  def change
    remove_column :test_case_results, :score, :float
    add_column :test_case_results, :pass, :boolean
  end
end
