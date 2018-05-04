class AddLmsAssignmentUrlToWorkoutOfferings < ActiveRecord::Migration
  def change
    add_column :workout_offerings, :lms_assignment_url, :string
  end
end
