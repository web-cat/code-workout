class AddIsPublicToWorkouts < ActiveRecord::Migration
  def change
    add_column :workouts, :is_public, :boolean
    add_index :workouts, :is_public
    add_index :exercises, :is_public
  end
end
