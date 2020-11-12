class AddDescriptionToUserGroups < ActiveRecord::Migration[5.1]
  def change
    add_column :user_groups, :description, :text
  end
end
