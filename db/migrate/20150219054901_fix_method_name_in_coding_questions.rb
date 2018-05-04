class FixMethodNameInCodingQuestions < ActiveRecord::Migration
  def change
    rename_column :coding_questions, :test_method, :method_name
  end
end
