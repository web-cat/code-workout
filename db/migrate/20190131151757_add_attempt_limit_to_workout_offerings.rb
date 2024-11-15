class AddAttemptLimitToWorkoutOfferings < ActiveRecord::Migration[5.1]
  def change
    add_column :workout_offerings, :attempt_limit, :integer, default: nil
  end
end
