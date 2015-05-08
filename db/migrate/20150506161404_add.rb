class Add < ActiveRecord::Migration
  def change
    add_column :exercises, :external_id, :string
    add_index :exercises, :external_id, unique: true
    add_column :workouts, :external_id, :string
    add_index :workouts, :external_id, unique: true
  end
end
