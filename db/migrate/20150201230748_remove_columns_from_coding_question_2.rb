class RemoveColumnsFromCodingQuestion2 < ActiveRecord::Migration
  def change
    remove_column :coding_questions, :wrapper_code
    remove_column :coding_questions, :test_script
  end
end
