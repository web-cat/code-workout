class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :name, null: false
      t.string :number, null: false
      t.integer :organization_id, null: false
      t.string :url_part, null: false

      t.timestamps
    end
  end
end
