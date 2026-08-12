class AddFeedbackTimesToAttempt < ActiveRecord::Migration[5.1]
  def change
    add_column :attempts, :time_taken, :decimal
    add_column :attempts, :feedback_timeout, :decimal
    add_column :attempts, :worker_time, :decimal
  end
end
