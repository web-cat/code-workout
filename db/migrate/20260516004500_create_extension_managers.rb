class CreateExtensionManagers < ActiveRecord::Migration[5.2]
  def change
    create_table :extension_managers do |t|
      t.string :name, null: false
      t.string :broker_base_url, null: false
      t.string :client_id, null: false
      t.string :client_secret, null: false

      t.timestamps
    end

    add_index :extension_managers, :broker_base_url, unique: true
    add_index :extension_managers, :client_id, unique: true
  end
end
