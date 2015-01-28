class AddVersionsToBaseExercises < ActiveRecord::Migration
  def change
    add_column :base_exercises, :versions, :integer
  end
end
