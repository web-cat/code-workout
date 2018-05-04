class RemoveDeadlinesFromWorkouts < ActiveRecord::Migration
  def change
    remove_column :workouts, :opening_date, :date
    remove_column :workouts, :soft_deadline, :date
    remove_column :workouts, :hard_deadline, :date
  end
end
