class RemoveNameFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :name, :string
  end
end
