class AddTargetGroupToWorkouts < ActiveRecord::Migration
  def change
    add_column :workouts, :target_group, :string
  end
end
