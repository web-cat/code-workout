class RemoveColumnsFromCodingQuestion < ActiveRecord::Migration[5.1]
  def change
    remove_column :coding_questions,  :base_class, :wrapper_code, :test_script
  end
end
