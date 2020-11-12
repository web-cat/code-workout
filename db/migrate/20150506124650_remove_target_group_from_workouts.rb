class RemoveTargetGroupFromWorkouts < ActiveRecord::Migration[5.1]
  def change
    remove_column :workouts, :target_group, :string
  end
end
