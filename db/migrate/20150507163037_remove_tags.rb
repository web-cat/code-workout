class RemoveTags < ActiveRecord::Migration[5.1]
  def up
    drop_table :exercises_tags
    remove_column :tag_user_scores, :tag_id, :integer
    drop_table :tags_workouts
    drop_table :tags
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
