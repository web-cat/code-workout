class AddColumnsToCodingQuestions < ActiveRecord::Migration
  def change
    add_column :coding_questions, :base_class, :string
    add_column :coding_questions, :wrapper_code, :text
    add_column :coding_questions, :test_script, :text
  end
end
