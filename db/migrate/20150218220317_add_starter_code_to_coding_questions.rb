class AddStarterCodeToCodingQuestions < ActiveRecord::Migration
  def change
    add_column :coding_questions, :starter_code, :text
  end
end
