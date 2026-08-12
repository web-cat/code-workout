class AddFeedbackToCodingQuestion < ActiveRecord::Migration[5.1]
  def change
    add_column :coding_questions, :feedback, :text
  end
end
