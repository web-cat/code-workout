class RenameVariationGroupToExerciseFamily < ActiveRecord::Migration
  def change
    rename_table :variation_groups, :exercise_families
    rename_column :exercises, :variation_group_id, :exercise_family_id
  end
end
