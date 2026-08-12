class AddTestMethodToCodingQuestions < ActiveRecord::Migration[5.1]
  def change
    add_column :coding_questions, :test_method, :string
  end
end
