class AddHardDeadlineToWorkouts < ActiveRecord::Migration
  def change
    add_column :workouts, :hard_deadline, :date
  end
end
