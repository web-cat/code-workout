class CreateWorkoutOwners < ActiveRecord::Migration[5.1]
  def change
    create_table :workout_owners do |t|
      t.belongs_to :workout, null: false
      t.bigint :owner_id, null: false
    end

    add_index :workout_owners, [:workout_id, :owner_id], unique: true
    add_foreign_key :workout_owners, :workouts
    add_foreign_key :workout_owners, :users, column: :owner_id

    rename_column :exercise_owners, :user_id, :owner_id
  end
end
