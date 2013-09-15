class CreateExercises < ActiveRecord::Migration
  def change
    create_table :exercises do |t|
      t.string :title, null: false
      t.text :preamble
      t.integer :user, null: false
      t.boolean :is_public, null: false

      t.timestamps
    end
  end
end
