class ChangeDatesToDatetimesInWorkoutOfferings < ActiveRecord::Migration[5.1]
  def change
    change_column :workout_offerings, :opening_date, :datetime
    change_column :workout_offerings, :soft_deadline, :datetime
    change_column :workout_offerings, :hard_deadline, :datetime
  end
end
