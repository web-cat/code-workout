class AddHardDeadlineToWorkouts < ActiveRecord::Migration[5.1]
  def change
    add_column :workouts, :hard_deadline, :date
  end
end
