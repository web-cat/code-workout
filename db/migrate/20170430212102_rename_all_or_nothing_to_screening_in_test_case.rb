class RenameAllOrNothingToScreeningInTestCase < ActiveRecord::Migration
  def change
    rename_column :test_cases, :all_or_nothing, :screening
  end
end
