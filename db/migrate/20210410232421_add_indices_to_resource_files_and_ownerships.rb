class AddIndicesToResourceFilesAndOwnerships < ActiveRecord::Migration[5.1]
  def change
    add_index :resource_files, :hashval
    add_index :ownerships, :filename
  end
end
