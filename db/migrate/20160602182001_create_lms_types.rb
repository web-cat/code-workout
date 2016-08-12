class CreateLmsTypes < ActiveRecord::Migration
  def change
    create_table :lms_types do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :lms_types, :name, unique: true
  end
end
