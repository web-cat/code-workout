class AddVariationGroupIdToBaseExercise < ActiveRecord::Migration
  def change
    add_column :base_exercises, :variation_group_id, :integer
  end
end
