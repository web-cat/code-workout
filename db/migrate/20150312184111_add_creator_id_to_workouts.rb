class AddCreatorIdToWorkouts < ActiveRecord::Migration[5.1]
  def change
    add_column :workouts, :creator_id, :integer
  end
end
