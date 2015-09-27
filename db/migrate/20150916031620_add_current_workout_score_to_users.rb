class AddCurrentWorkoutScoreToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.integer :current_workout_score_id
      t.index :current_workout_score_id, unique: true
      t.foreign_key :workout_scores, column: :current_workout_score_id
    end
  end
end
