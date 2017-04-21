class ChangeTagsInExercise < ActiveRecord::Migration
  def change
  	remove_column :exercises, :language, :belongs_to #language now represented as a tag with tagtype=2
  end
end
