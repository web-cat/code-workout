class AddFeedbackReadyToAttempts < ActiveRecord::Migration[5.1]
  def change
    add_column :attempts, :feedback_ready, :boolean
  end
end
