class RenameCurrentVersionToCurrentVersionIdInBaseExercises < ActiveRecord::Migration
  def change
    rename_column :base_exercises, :current_version, :current_version_id
  end
end
