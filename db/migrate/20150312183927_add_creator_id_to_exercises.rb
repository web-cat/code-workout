class AddCreatorIdToExercises < ActiveRecord::Migration
  def change
    add_column :exercises, :creator_id, :integer
  end
end
