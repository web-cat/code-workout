class RenameTitleToNameInExercises < ActiveRecord::Migration[5.1]
  def change
    rename_column :exercises, :title, :name
  end
end
