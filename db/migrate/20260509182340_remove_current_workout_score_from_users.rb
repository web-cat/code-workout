class RemoveCurrentWorkoutScoreFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :current_workout_score_id, :integer
  end
end
