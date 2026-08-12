class AddHashvalToResourceFile < ActiveRecord::Migration[5.1]
  def change
    add_column :resource_files, :hashval, :string
  end
end
