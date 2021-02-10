class CreateOwnerships < ActiveRecord::Migration
  def change
    create_table :ownerships do |t|
      t.string :filename
      t.references :resource_file, index: true, foreign_key: true
      t.references :exercise_version, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
