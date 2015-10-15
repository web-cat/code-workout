class AddTimeLimitToWorkoutOfferings < ActiveRecord::Migration
  def change
    add_column :workout_offerings, :time_limit, :int
  end
end
