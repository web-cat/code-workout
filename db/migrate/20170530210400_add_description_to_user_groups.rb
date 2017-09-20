class AddDescriptionToUserGroups < ActiveRecord::Migration
  def change
    add_column :user_groups, :description, :text
  end
end
