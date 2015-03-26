class RenameTitleToNameInExercises < ActiveRecord::Migration
  def change
    rename_column :exercises, :title, :name
  end
end
