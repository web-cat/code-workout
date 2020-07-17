class AddCollectionTypesToExerciseCollections < ActiveRecord::Migration
  def change
    # changes to exercise_collections
    add_column :exercise_collections, :type, :string, null: false
    add_column :exercise_collections, :can_opt_in, :boolean, default: false
    remove_reference :exercise_collections, :course_offering, index: true
  end
end
