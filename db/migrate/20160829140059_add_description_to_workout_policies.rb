class AddDescriptionToWorkoutPolicies < ActiveRecord::Migration[5.1]
  def change
    add_column :workout_policies, :description, :string
  end
end
