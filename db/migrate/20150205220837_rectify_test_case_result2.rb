class RectifyTestCaseResult2 < ActiveRecord::Migration
  def change
    remove_column :test_case_results, :max, :boolean
  end
end
