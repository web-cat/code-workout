class AddMultipleAttemptsToWorkoutOfferings < ActiveRecord::Migration[5.2]
  def change
    add_column :workout_offerings, :workout_attempt_limit, :integer, default: 1
    add_column :workout_offerings, :score_to_keep, :boolean, default: false, null: false

    add_column :student_extensions, :workout_attempt_limit, :integer, default: nil

    add_column :workout_scores, :attempt_number, :integer, default: 1, null: false
    add_index :workout_scores, [:user_id, :workout_offering_id, :attempt_number],
              name: 'idx_ws_user_offering_attempt'
  end
end
