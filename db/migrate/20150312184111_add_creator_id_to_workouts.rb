class AddCreatorIdToWorkouts < ActiveRecord::Migration
  def change
    add_column :workouts, :creator_id, :integer
  end
end
