class AddLtiAssignmentIdToWorkoutOfferings < ActiveRecord::Migration[5.2]
  def change
    add_column :workout_offerings, :lti_assignment_id, :string
    add_index :workout_offerings, :lti_assignment_id
  end
end
