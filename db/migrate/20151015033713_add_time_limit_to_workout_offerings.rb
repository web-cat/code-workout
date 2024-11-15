class AddTimeLimitToWorkoutOfferings < ActiveRecord::Migration[5.1]
  def change
    add_column :workout_offerings, :time_limit, :int
  end
end
