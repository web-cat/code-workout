class AddAttemptLimitToWorkoutOfferings < ActiveRecord::Migration
  def change
    add_column :workout_offerings, :attempt_limit, :integer, default: nil
  end
end
