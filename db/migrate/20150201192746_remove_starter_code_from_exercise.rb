class RemoveStarterCodeFromExercise < ActiveRecord::Migration
  def change
    remove_column :exercises, :starter_code, :text
  end
end
