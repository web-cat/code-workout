class RenameDisplayNameToNameInOrganizations < ActiveRecord::Migration[5.1]
  def change
    rename_column :organizations, :display_name, :name
  end
end
