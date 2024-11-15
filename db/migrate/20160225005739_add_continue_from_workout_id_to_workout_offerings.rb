class AddContinueFromWorkoutIdToWorkoutOfferings < ActiveRecord::Migration[5.1]
  def change
    change_table :workout_offerings do |t|
      t.integer :continue_from_workout_id
      t.foreign_key :workout_offerings, column: :continue_from_workout_id,
        index: true
    end
  end
end
