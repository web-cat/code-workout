class RemoveStarterCodeFromExercise < ActiveRecord::Migration[5.1]
  def change
    remove_column :exercises, :starter_code, :text
  end
end
