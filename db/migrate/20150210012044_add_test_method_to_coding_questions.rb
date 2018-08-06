class AddTestMethodToCodingQuestions < ActiveRecord::Migration
  def change
    add_column :coding_questions, :test_method, :string
  end
end
