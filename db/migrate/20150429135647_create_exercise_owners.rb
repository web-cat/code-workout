class CreateExerciseOwners < ActiveRecord::Migration
  def change
    create_table :exercise_owners do |t|
      t.belongs_to :exercise, null: false
      t.belongs_to :user, null: false
    end

    add_index :exercise_owners, [:exercise_id, :user_id], unique: true
    add_foreign_key :exercise_owners, :exercises
    add_foreign_key :exercise_owners, :users
  end
end
