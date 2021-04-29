class AddDimensionToResourceFiles < ActiveRecord::Migration
  def change
    add_column :resource_files, :x_dimension, :integer
    add_column :resource_files, :y_dimension, :integer
    add_column :resource_files, :size, :integer
  end
end
