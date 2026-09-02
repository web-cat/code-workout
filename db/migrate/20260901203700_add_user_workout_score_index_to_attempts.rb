class AddUserWorkoutScoreIndexToAttempts < ActiveRecord::Migration[5.2]
  def change
    add_index :attempts,
              [:user_id, :workout_score_id, :exercise_version_id, :updated_at],
              name: 'idx_attempts_on_user_ws_ver_updated'
  end
end
