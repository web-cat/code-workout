class AddMostRecentToWorkoutOfferings < ActiveRecord::Migration
  def change
    add_column :workout_offerings, :most_recent, :boolean, default: true
  end
end
