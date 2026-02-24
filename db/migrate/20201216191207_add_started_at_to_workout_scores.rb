class AddStartedAtToWorkoutScores < ActiveRecord::Migration[5.1]
  def change
    add_column :workout_scores, :started_at, :datetime

    reversible do |dir|
      dir.up do
        WorkoutScore.update_all('started_at = created_at')
      end
      dir.down do
        # Nothing
      end
    end

  end
end
