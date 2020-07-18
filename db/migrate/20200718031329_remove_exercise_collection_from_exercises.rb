class RemoveExerciseCollectionFromExercises < ActiveRecord::Migration
  def change
    # Move all belongs_to exercise_collection associations to the new join table
    execute <<-SQL
      INSERT INTO exercise_collection_memberships (exercise_id, exercise_collection_id)
      SELECT id, exercise_collection_id
      FROM exercises
      WHERE exercises.exercise_collection_id IS NOT NULL
    SQL

    # remove the exercise_collection_id reference from exercises
    remove_reference :exercises, :exercise_collection
  end
end
