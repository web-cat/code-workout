class RemoveCreatorIdFromBaseExercises < ActiveRecord::Migration
  def change
    remove_column :base_exercises, :creator_id, :integer
  end
end
