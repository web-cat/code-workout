class RenameCurrentVersionToCurrentVersionIdInBaseExercises < ActiveRecord::Migration[5.1]
  def change
    rename_column :base_exercises, :current_version, :current_version_id
  end
end
