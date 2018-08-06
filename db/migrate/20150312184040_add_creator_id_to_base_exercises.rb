class AddCreatorIdToBaseExercises < ActiveRecord::Migration
  def change
    add_column :base_exercises, :creator_id, :integer
  end
end
