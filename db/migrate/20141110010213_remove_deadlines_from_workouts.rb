class RemoveDeadlinesFromWorkouts < ActiveRecord::Migration[5.1]
  def change
    remove_column :workouts, :opening_date, :date
    remove_column :workouts, :soft_deadline, :date
    remove_column :workouts, :hard_deadline, :date
  end
end
