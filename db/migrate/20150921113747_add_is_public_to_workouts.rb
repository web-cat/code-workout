class AddIsPublicToWorkouts < ActiveRecord::Migration[5.1]
  def change
    add_column :workouts, :is_public, :boolean
    add_index :workouts, :is_public
    add_index :exercises, :is_public
  end
end
