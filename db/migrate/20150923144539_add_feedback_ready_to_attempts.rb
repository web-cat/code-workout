class AddFeedbackReadyToAttempts < ActiveRecord::Migration
  def change
    add_column :attempts, :feedback_ready, :boolean
  end
end
