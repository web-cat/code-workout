class AddInvisibleBeforeReviewToWorkoutPolicies < ActiveRecord::Migration
  def change
    add_column :workout_policies, :invisible_before_review, :boolean
  end
end
