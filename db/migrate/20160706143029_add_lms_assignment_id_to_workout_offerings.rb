class AddLmsAssignmentIdToWorkoutOfferings < ActiveRecord::Migration
  def change
    add_column :workout_offerings, :lms_assignment_id, :string

    add_index :workout_offerings, :lms_assignment_id, unique: true
  end
end
