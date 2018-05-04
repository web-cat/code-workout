class AddIsHiddenToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :is_hidden, :boolean, default: false
  end
end
