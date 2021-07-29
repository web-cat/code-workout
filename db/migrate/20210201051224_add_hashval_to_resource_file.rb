class AddHashvalToResourceFile < ActiveRecord::Migration
  def change
    add_column :resource_files, :hashval, :string
  end
end
