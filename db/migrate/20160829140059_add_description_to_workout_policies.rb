class AddDescriptionToWorkoutPolicies < ActiveRecord::Migration
  def change
    add_column :workout_policies, :description, :string
  end
end
