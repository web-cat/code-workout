class AddWorkoutToAttempts < ActiveRecord::Migration
  def change
    add_column :attempts, :workout_id, :integer
  end
end
