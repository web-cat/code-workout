class RenameTagName < ActiveRecord::Migration[5.1]
  def change
  	rename_column :tags, :name, :tag_name
  end
end
