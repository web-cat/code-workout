class RemoveNameAndDescriptionFromWorkoutPolicies < ActiveRecord::Migration[5.2]
  def change
    remove_column :workout_policies, :name, :string
    remove_column :workout_policies, :description, :string
  end
end
