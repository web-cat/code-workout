class AddCompoundIndexToAttempts < ActiveRecord::Migration
  def change
    add_index :attempts, [:user_id, :exercise_version_id],
              name: 'idx_attempts_on_user_exercise_version'
    add_index :attempts, [:workout_score_id, :exercise_version_id],
              name: 'idx_attempts_on_workout_score_exercise_version'
  end
end
