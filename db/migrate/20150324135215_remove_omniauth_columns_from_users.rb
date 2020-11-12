class RemoveOmniauthColumnsFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :provider, :string
    remove_column :users, :uid, :string
  end
end
