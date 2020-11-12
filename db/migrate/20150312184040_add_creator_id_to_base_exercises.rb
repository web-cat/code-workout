class AddCreatorIdToBaseExercises < ActiveRecord::Migration[5.1]
  def change
    add_column :base_exercises, :creator_id, :integer
  end
end
