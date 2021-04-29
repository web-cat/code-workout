class RenameFileToFileInResourceFiles < ActiveRecord::Migration
  def up
    rename_column :resource_files, :file, :filename
  end

  def down
    rename_column :resource_files, :filename, :file
  end
end
