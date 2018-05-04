class RenamePositionToVersionInExerciseVersions < ActiveRecord::Migration
  def change
    rename_column :exercise_versions, :position, :version
    change_column_null :exercises, :versions, true
  end
end
