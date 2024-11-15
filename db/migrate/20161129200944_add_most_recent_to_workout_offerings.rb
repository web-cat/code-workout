class AddMostRecentToWorkoutOfferings < ActiveRecord::Migration[5.1]
  def change
    add_column :workout_offerings, :most_recent, :boolean, default: true
  end
end
