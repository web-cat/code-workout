class AddOpeningDateToWorkouts < ActiveRecord::Migration
  def change
    add_column :workouts, :opening_date, :date
  end
end
