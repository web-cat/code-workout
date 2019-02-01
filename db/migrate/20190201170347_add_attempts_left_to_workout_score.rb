class AddAttemptsLeftToWorkoutScore < ActiveRecord::Migration
  def change
    add_column :workout_scores, :attempts_left, :integer, default: nil
  end
end
