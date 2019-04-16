class AddFeedbackTimesToAttempt < ActiveRecord::Migration
  def change
    add_column :attempts, :time_taken, :integer
    add_column :attempts, :feedback_timeout, :integer
  end
end
