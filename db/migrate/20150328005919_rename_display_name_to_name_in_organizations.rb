class RenameDisplayNameToNameInOrganizations < ActiveRecord::Migration
  def change
    rename_column :organizations, :display_name, :name
  end
end
