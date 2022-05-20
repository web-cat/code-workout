class AddIndicesToResourceFilesAndOwnerships < ActiveRecord::Migration
  def change
    add_index :resource_files, :hashval
    add_index :ownerships, :filename
  end
end
