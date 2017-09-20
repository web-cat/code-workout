class CreateExerciseCollections < ActiveRecord::Migration
  def change
    create_table :exercise_collections do |t|
      t.string :name
      t.text :description
      t.references :user_group, index: true, foreign_key: true
      t.references :license, index: true, foreign_key: true

      t.timestamps
    end
  end
end
