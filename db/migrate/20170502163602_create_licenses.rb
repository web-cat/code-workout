class CreateLicenses < ActiveRecord::Migration[5.1]
  def change
    create_table :licenses do |t|
      t.string :name
      t.text :description
      t.string :url
      t.references :license_policy, index: true, foreign_key: true

      t.timestamps
    end
  end
end
