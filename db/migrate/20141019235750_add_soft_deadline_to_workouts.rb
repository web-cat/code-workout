class AddSoftDeadlineToWorkouts < ActiveRecord::Migration[5.1]
  def change
    add_column :workouts, :soft_deadline, :date
  end
end
