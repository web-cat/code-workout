class AddPublishedToWorkoutOfferings < ActiveRecord::Migration[5.1]
  def change
    add_column :workout_offerings, :published, :boolean,
      null: false, default: true
  end
end
