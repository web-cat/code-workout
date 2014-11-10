class AddSoftDeadlineToWorkouts < ActiveRecord::Migration
  def change
    add_column :workouts, :soft_deadline, :date
  end
end
