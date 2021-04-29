class RenameFilenameToFileInResourceFiles < ActiveRecord::Migration
  def up
    rename_column :resource_files, :filename, :file
  end

  def down
    rename_column :resource_files, :file, :filename
  end
end
