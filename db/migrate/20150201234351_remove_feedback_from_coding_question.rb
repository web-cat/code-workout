class RemoveFeedbackFromCodingQuestion < ActiveRecord::Migration[5.1]
  def change
    remove_column :coding_questions, :feedback, :text
  end
end
