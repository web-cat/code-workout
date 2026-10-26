class RenameScoreToKeepAndMostRecentOnWorkoutOfferings < ActiveRecord::Migration[5.2]
  def change
    rename_column :workout_offerings, :score_to_keep, :workout_score_to_keep
    rename_column :workout_offerings, :most_recent, :exercise_score_to_keep
  end
end
