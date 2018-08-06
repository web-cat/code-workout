class RemoveNullConstraintFromExerciseCurrentVersion < ActiveRecord::Migration
  def change
    change_column_null :exercises, :current_version_id, true
  end
end
