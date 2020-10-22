class AddTargetGroupToWorkouts < ActiveRecord::Migration[5.1]
  def change
    add_column :workouts, :target_group, :string
  end
end
