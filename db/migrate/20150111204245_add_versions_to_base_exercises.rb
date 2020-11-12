class AddVersionsToBaseExercises < ActiveRecord::Migration[5.1]
  def change
    add_column :base_exercises, :versions, :integer
  end
end
