class RemoveFeedbackFromCodingQuestion < ActiveRecord::Migration
  def change
    remove_column :coding_questions, :feedback, :text
  end
end
