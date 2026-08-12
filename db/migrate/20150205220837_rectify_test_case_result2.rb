class RectifyTestCaseResult2 < ActiveRecord::Migration[5.1]
  def change
    remove_column :test_case_results, :max, :boolean
  end
end
