class RemoveColumnsFromCodingQuestion2 < ActiveRecord::Migration[5.1]
  def change
    remove_column :coding_questions, :wrapper_code
    remove_column :coding_questions, :test_script
  end
end
