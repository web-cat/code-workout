class RemoveUserIdFromExercises < ActiveRecord::Migration[5.1]
  def change
    remove_column :exercises, :user_id, :integer
  end
end
