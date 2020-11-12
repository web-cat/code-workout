class AddStarterCodeToCodingQuestions < ActiveRecord::Migration[5.1]
  def change
    add_column :coding_questions, :starter_code, :text
  end
end
