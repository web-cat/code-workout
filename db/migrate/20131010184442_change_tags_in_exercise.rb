class ChangeTagsInExercise < ActiveRecord::Migration[5.1]
  def change
    # remove_foreign_key :exercises, :languages
  	remove_column :exercises, :language_id, :integer #language now represented as a tag with tagtype=2
  end
end
