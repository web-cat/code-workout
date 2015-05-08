class MoveTagsFromExerciseVersionsToExercises < ActiveRecord::Migration
  def up
    drop_table :exercise_versions_tags
    create_table :exercises_tags, id: false do |t|
      t.belongs_to :exercise, null: false
      t.belongs_to :tag, null: false

      t.foreign_key :exercises
      t.foreign_key :tags
    end

    add_index :exercises_tags, [:exercise_id, :tag_id], unique: true
  end

  def down
    drop_table :exercises_tags
    create_table :exercise_versions_tags, id: false do |t|
      t.belongs_to :exercise_version, null: false
      t.belongs_to :tag, null: false

      t.foreign_key :exercise_versions
      t.foreign_key :tags
    end

    add_index :exercise_versions_tags, [:exercise_version_id, :tag_id],
      unique: true
  end
end
