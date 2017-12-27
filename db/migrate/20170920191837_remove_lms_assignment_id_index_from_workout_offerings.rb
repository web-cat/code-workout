class RemoveLmsAssignmentIdIndexFromWorkoutOfferings < ActiveRecord::Migration
  def change
    remove_index :workout_offerings, :lms_assignment_id # remove it to get rid of unique requirement

    add_index :workout_offerings, :lms_assignment_id # add it again to keep search speed
  end
end
