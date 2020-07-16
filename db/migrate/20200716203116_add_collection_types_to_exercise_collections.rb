class AddCollectionTypesToExerciseCollections < ActiveRecord::Migration
  def change
    add_column :exercise_collections, :type, :string, null: false
    add_column :exercise_collections, :can_opt_in, :boolean, default: false
  end
end
