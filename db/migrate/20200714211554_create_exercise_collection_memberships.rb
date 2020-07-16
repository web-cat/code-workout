class CreateExerciseCollectionMemberships < ActiveRecord::Migration
  def change
    create_table :exercise_collection_memberships do |t|
      t.references :exercise_collection
      t.references :exercise
      t.boolean :is_collection_public, default: false
      t.timestamps null: false
    end
  end
end
