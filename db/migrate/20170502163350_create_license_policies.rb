class CreateLicensePolicies < ActiveRecord::Migration
  def change
    create_table :license_policies do |t|
      t.string :name
      t.text :description
      t.boolean :can_fork
      t.boolean :is_public

      t.timestamps
    end
  end
end
