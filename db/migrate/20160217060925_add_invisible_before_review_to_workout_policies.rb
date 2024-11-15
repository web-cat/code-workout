class AddInvisibleBeforeReviewToWorkoutPolicies < ActiveRecord::Migration[5.1]
  def change
    add_column :workout_policies, :invisible_before_review, :boolean
  end
end
