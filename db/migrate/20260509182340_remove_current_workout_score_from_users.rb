class RemoveCurrentWorkoutScoreFromUsers < ActiveRecord::Migration[5.2]
  def change
    if foreign_key_exists?(:users, name: "users_current_workout_score_id_fk")
      remove_foreign_key :users, name: "users_current_workout_score_id_fk"
    elsif foreign_key_exists?(:users, column: :current_workout_score_id)
      remove_foreign_key :users, column: :current_workout_score_id
    end
    remove_column :users, :current_workout_score_id, :integer if column_exists?(:users, :current_workout_score_id)
  end
end
