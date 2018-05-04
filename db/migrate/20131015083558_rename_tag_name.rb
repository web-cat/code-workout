class RenameTagName < ActiveRecord::Migration
  def change
  	rename_column :tags, :name, :tag_name
  end
end
