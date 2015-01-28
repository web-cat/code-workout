class CreateWorkoutScores < ActiveRecord::Migration
  def change
    create_table :workout_scores do |t|
      t.belongs_to :workout, index: true
      t.belongs_to :user, index: true
      t.float :score
      t.boolean :completed
      t.timestamp :completed_at
      t.timestamp :last_attempted_at
      t.integer :exercises_completed
      t.integer :exercises_remaining

      t.timestamps
    end
  end
end
