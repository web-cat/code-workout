class RemoveUserIdFromBaseExercises < ActiveRecord::Migration
  def change
    remove_column :exercises, :user_id, :integer
  end
end
