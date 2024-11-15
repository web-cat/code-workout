class AddVersionToExercise < ActiveRecord::Migration[5.1]
  def change
    add_column :exercises, :version, :integer
  end
end
