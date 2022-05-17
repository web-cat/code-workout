class AddDescriptionToStudentTestCases < ActiveRecord::Migration
  def change
    add_column :student_test_cases, :description, :text
  end
end
