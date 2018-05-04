class AddPointsMultiplierToWorkouts < ActiveRecord::Migration
  def change
    add_column :workouts, :points_multiplier, :integer
  end
end
