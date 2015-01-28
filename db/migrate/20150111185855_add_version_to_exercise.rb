class AddVersionToExercise < ActiveRecord::Migration
  def change
    add_column :exercises, :version, :integer
  end
end
