class FixMethodNameInCodingQuestions < ActiveRecord::Migration[5.1]
  def change
    rename_column :coding_questions, :test_method, :method_name
  end
end
