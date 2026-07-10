class RemoveCurrentWorkoutScoreFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :users, name: "users_current_workout_score_id_fk"
    remove_column :users, :current_workout_score_id, :integer
  end
end
