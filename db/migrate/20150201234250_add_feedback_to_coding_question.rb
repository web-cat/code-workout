class AddFeedbackToCodingQuestion < ActiveRecord::Migration
  def change
    add_column :coding_questions, :feedback, :text
  end
end
