class CreateOrganizations < ActiveRecord::Migration[5.1]
  def change
    create_table :organizations do |t|
      t.string :display_name, null: false
      t.string :url_part, null: false

      t.timestamps
    end

    add_index :organizations, :display_name, unique: true
    add_index :organizations, :url_part,     unique: true
  end
end
