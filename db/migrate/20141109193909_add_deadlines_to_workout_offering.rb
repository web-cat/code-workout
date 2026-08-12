class AddDeadlinesToWorkoutOffering < ActiveRecord::Migration[5.1]
  def change
    add_column :workout_offerings, :opening_date, :date
    add_column :workout_offerings, :soft_deadline, :date
    add_column :workout_offerings, :hard_deadline, :date
  end
end
