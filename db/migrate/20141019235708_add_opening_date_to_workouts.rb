class AddOpeningDateToWorkouts < ActiveRecord::Migration[5.1]
  def change
    add_column :workouts, :opening_date, :date
  end
end
