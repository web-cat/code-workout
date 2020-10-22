class RemoveNullConstraintFromExerciseCurrentVersion < ActiveRecord::Migration[5.1]
  def change
    change_column_null :exercises, :current_version_id, true
  end
end
