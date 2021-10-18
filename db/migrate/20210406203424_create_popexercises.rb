class CreatePopexercises < ActiveRecord::Migration
  def change
    create_table :popexercises do |t|
      t.string :exercise_id
      t.text :code

      t.timestamps
    end
  end
end
