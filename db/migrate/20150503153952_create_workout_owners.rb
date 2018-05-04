class CreateWorkoutOwners < ActiveRecord::Migration
  def change
    create_table :workout_owners do |t|
      t.belongs_to :workout, null: false
      t.integer :owner_id, null: false
    end

    add_index :workout_owners, [:workout_id, :owner_id], unique: true
    add_foreign_key :workout_owners, :workouts
    add_foreign_key :workout_owners, :users, foreign_key: :owner_id

    rename_column :exercise_owners, :user_id, :owner_id
  end
end
