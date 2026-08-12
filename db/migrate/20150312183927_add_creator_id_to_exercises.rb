class AddCreatorIdToExercises < ActiveRecord::Migration[5.1]
  def change
    add_column :exercises, :creator_id, :integer
  end
end
