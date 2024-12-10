class AddCompoundIndexToWorkoutScores < ActiveRecord::Migration
  def change
    add_index :workout_scores, [:user_id, :workout_id, :workout_offering_id],
              name: 'idx_ws_on_user_workout_workout_offering'
  end
end
