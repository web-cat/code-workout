class CreateWorkouts < ActiveRecord::Migration
  def change
    create_table :workouts do |t|
      t.string :name, null: false  
      t.boolean :scrambled, default: false
      t.timestamps
    end

    create_table :workouts_exercises do |t|
      t.belongs_to :workout, null: false, index: true
      t.belongs_to :exercise, null: false, index: true
      t.integer :points
      t.integer :order
      t.timestamps
    end
  end
end
