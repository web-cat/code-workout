class AddIsHiddenToOrganization < ActiveRecord::Migration[5.1]
  def change
    add_column :organizations, :is_hidden, :boolean, default: false
  end
end
