class AddPointsMultiplierToWorkouts < ActiveRecord::Migration[5.1]
  def change
    add_column :workouts, :points_multiplier, :integer
  end
end
