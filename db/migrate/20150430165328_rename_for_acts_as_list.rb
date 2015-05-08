class RenameForActsAsList < ActiveRecord::Migration
  def change
    rename_column :choices, :order, :position
    rename_column :exercise_versions, :version, :position
    rename_column :prompts, :order, :position
    rename_column :exercise_workouts, :order, :position
  end
end
