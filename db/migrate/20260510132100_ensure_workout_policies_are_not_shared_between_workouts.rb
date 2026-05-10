class EnsureWorkoutPoliciesAreNotSharedBetweenWorkouts < ActiveRecord::Migration[5.2]
  def up
    # Iterate through each policy to check if it's shared across different workouts
    WorkoutPolicy.find_each do |policy|
      # Find all unique workout IDs that use this policy
      workout_ids = WorkoutOffering.where(workout_policy_id: policy.id).pluck(:workout_id).uniq
      
      if workout_ids.size > 1
        # The policy is shared between multiple workouts.
        # Keep it for the first workout, and clone it for the others.
        workout_ids[1..-1].each do |workout_id|
          # Clone the policy
          new_policy = policy.dup
          new_policy.save!
          
          # Update all offerings for this specific workout to use the new clone
          WorkoutOffering.where(workout: workout_id, workout_policy_id: policy.id)
                        .update_all(workout_policy_id: new_policy.id)
        end
      end
    end
  end

  def down
    # This migration is not easily reversible as we've split shared records.
    raise ActiveRecord::IrreversibleMigration
  end
end
