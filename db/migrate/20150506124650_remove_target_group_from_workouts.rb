class RemoveTargetGroupFromWorkouts < ActiveRecord::Migration
  def change
    remove_column :workouts, :target_group, :string
  end
end
