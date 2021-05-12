class AddHasAttemptedToWorkoutScore < ActiveRecord::Migration
  def change
    add_column :workout_scores, :has_attempted, :boolean
  end
end
