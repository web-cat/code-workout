class RemoveCreatorIdFromBaseExercises < ActiveRecord::Migration[5.1]
  def change
    remove_column :base_exercises, :creator_id, :integer
  end
end
