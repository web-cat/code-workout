class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :display_name, null: false
      t.string :url_part, null: false

      t.timestamps
    end
  end
end
